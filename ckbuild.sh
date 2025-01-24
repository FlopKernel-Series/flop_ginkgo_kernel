#!/bin/bash
#
# Build script for FloppyKernel.
# Based on build script for Quicksilver, by Ghostrider.
# Copyright (C) 2020-2021 Adithya R. (original version)
# Copyright (C) 2022-2024 Flopster101 (rewrite)

## Vars
# Toolchains
AOSP_REPO="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/heads/master"
AOSP_ARCHIVE="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master"
SD_REPO="https://github.com/ThankYouMario/proprietary_vendor_qcom_sdclang"
SD_BRANCH="14"
PC_REPO="https://github.com/kdrag0n/proton-clang"
LZ_REPO="https://gitlab.com/Jprimero15/lolz_clang.git"
RC_URL="https://github.com/kutemeikito/RastaMod69-Clang/releases/download/RastaMod69-Clang-20.0.0-release/RastaMod69-Clang-20.0.0.tar.gz"
# AnyKernel3
AK3_URL="https://github.com/Flopster101/AnyKernel3"
AK3_BRANCH="carakernel-new"

# Workspace
if [ -d /workspace ]; then
    WP="/workspace"
    IS_GP=1
else
    IS_GP=0
fi
if [ -z "$WP" ]; then
    echo -e "\nERROR: Environment not Gitpod! Please set the WP env var...\n"
    exit 1
fi

if [ ! -d drivers ]; then
    echo -e "\nERROR: Please exec from top-level kernel tree\n"
    exit 1
fi

if [ "$IS_GP" = "1" ]; then
    export KBUILD_BUILD_USER="Flopster101"
    export KBUILD_BUILD_HOST="buildbot"
fi

# Other
DEFAULT_DEFCONFIG="carakernel_defconfig"
KERNEL_URL="https://github.com/Flopster101/flop_ginkgo_kernel"
SECONDS=0 # builtin bash timer
DATE="$(date '+%Y%m%d-%H%M')"
# Paths
SD_DIR="$WP/sdclang"
AC_DIR="$WP/aospclang"
PC_DIR="$WP/protonclang"
RC_DIR="$WP/rm69clang"
LZ_DIR="$WP/lolzclang"
GCC_DIR="$WP/gcc"
GCC64_DIR="$WP/gcc64"
AK3_DIR="$WP/AnyKernel3"
KDIR="$(readlink -f .)"
OUT_IMAGE="out/arch/arm64/boot/Image.gz-dtb"
OUT_DTBO="out/arch/arm64/boot/dtbo.img"

## Customizable vars

# FloppyKernel version
CK_VER="MS25"

# Toggles
USE_CCACHE="1"

## Parse arguments
DO_KSU=0
DO_CLEAN=0
DO_MENUCONFIG=0
IS_RELEASE=0
DO_TG=0
for arg in "$@"
do
    if [[ "$arg" == *m* ]]; then
        echo -e "\nINFO: menuconfig argument passed, kernel configuration menu will be shown..."
        DO_MENUCONFIG=1
    fi
    if [[ "$arg" == *k* ]]; then
        echo -e "\nINFO: KernelSU argument passed, a KernelSU build will be made..."
        DO_KSU=1
    fi
    if [[ "$arg" == *c* ]]; then
        echo -e "\nINFO: clean argument passed, output directory will be wiped..."
        DO_CLEAN=1
    fi
    if [[ "$arg" == *R* ]]; then
        echo -e "\nINFO: Release argument passed, build marked as release"
        IS_RELEASE=1
    fi
    if [[ "$arg" == *t* ]]; then
        echo -e "\nINFO: Telegram argument passed, build will be uploaded to CI"
        DO_TG=1
    fi
    if [[ "$arg" == *o* ]]; then
        echo -e "\nINFO: oshi.at argument passed, build will be uploaded to oshi.at"
        DO_OSHI=1
    fi
done

DEFCONFIG=$DEFAULT_DEFCONFIG
if [ $DO_KSU = "1" ]; then
    DEFCONFIG="carakernel-ksu_defconfig"
else
    DEFCONFIG="carakernel_defconfig"
fi

if [[ "${IS_RELEASE}" = "1" ]]; then
    BUILD_TYPE="Release"
else
    echo -e "\nINFO: Build marked as testing"
    BUILD_TYPE="Testing"
fi

IS_RELEASE=0
TEST_CHANNEL=1
#TEST_BUILD=0

# Upload build log
LOG_UPLOAD=1

# Pick aosp, proton, rm69, sdclang or lolz
CLANG_TYPE=aosp

## Info message
LINKER=ld.lld
DEVICE="Redmi Note 8/8T"
CODENAME="ginkgo"

## Secrets
if [[ "${TEST_CHANNEL}" = "0" ]]; then
    TELEGRAM_CHAT_ID="$(cat ../chat)"
elif [[ "${TEST_CHANNEL}" = "1" ]]; then
    TELEGRAM_CHAT_ID="$(cat ../chat_test)"
fi
TELEGRAM_BOT_TOKEN=$(cat ../bot_token)

## Build type
LINUX_VER=$(make kernelversion 2>/dev/null)

if [[ "${IS_RELEASE}" = "1" ]]; then
    BUILD_TYPE="Release"
else
    BUILD_TYPE="Testing"
fi

CK_TYPE=""
if [ $DO_KSU -eq 1 ]; then
    CK_TYPE="KSU"
else
    CK_TYPE="Vanilla"
fi
ZIP_PATH="$WP/FloppyKernel_$CK_VER-$CK_TYPE-ginkgo-$DATE.zip"

echo -e "\nINFO: Build info:
- KernelSU: $( [ "$DO_KSU" -eq 1 ] && echo Yes || echo No )
- FloppyKernel version: $CK_VER
- Linux version: $LINUX_VER
- Defconfig: $DEFCONFIG
- Build date: $DATE
- Build type: $BUILD_TYPE
- Clean build: $( [ "$DO_CLEAN" -eq 1 ] && echo Yes || echo No )
"

install_deps_deb() {
    # Dependencies
    UB_DEPLIST="lz4 brotli flex bc cpio kmod ccache zip libtinfo5 python3"
    if grep -q "Ubuntu" /etc/os-release; then
        sudo apt install $UB_DEPLIST -y
    else
        echo -e "INFO: Your distro is not Ubuntu, skipping dependencies installation..."
        echo -e "INFO: Make sure you have these dependencies installed before proceeding: $UB_DEPLIST"
    fi
}

get_toolchain() {
    # Snapdragon Clang
    if [[ $1 = "sdclang" ]]; then
        if ! [ -d "$SD_DIR" ]; then
            echo -e "\nINFO: SD Clang not found! Cloning to $SD_DIR..."
            if ! git clone -q -b $SD_BRANCH --depth=1 $SD_REPO $SD_DIR; then
                echo -e "\nERROR: Cloning failed! Aborting..."
                exit 1
            fi
        fi
    fi

    # AOSP Clang
    if [[ $1 = "aosp" ]]; then
        if ! [ -d "$AC_DIR" ]; then
            CURRENT_CLANG=$(curl $AOSP_REPO | grep -oE "clang-r[0-9a-f]+" | sort -u | tail -n1)
            echo -e "\nINFO: AOSP Clang not found! Cloning to $AC_DIR..."
            if ! curl -LSsO "$AOSP_ARCHIVE/$CURRENT_CLANG.tar.gz"; then
                echo -e "\nERROR: Cloning failed! Aborting..."
                exit 1
            fi
            mkdir -p $AC_DIR && tar -xf ./*.tar.gz -C $AC_DIR && rm ./*.tar.gz && rm -rf clang
            touch $AC_DIR/bin/aarch64-linux-gnu-elfedit && chmod +x $AC_DIR/bin/aarch64-linux-gnu-elfedit
            touch $AC_DIR/bin/arm-linux-gnueabi-elfedit && chmod +x $AC_DIR/bin/arm-linux-gnueabi-elfedit
            rm -rf $CURRENT_CLANG
        fi
    fi

    # Proton Clang
    if [[ $1 = "proton" ]]; then
        if ! [ -d "$PC_DIR" ]; then
            echo -e "\nINFO: Proton Clang not found! Cloning to $PC_DIR..."
            if ! git clone -q --depth=1 $PC_REPO $PC_DIR; then
                echo -e "\nERROR: Cloning failed! Aborting..."
                exit 1
            fi
        fi
    fi

    # RastaMod69 Clang
    if [[ $1 = "rm69" ]]; then
        if ! [ -d "$RC_DIR" ]; then
            echo -e "\nINFO: RastaMod69 Clang not found! Cloning to $RC_DIR..."
            
            # Download and extract RastaMod69 Clang
            wget -q --show-progress $RC_URL -O "$WP/RastaMod69-clang.tar.gz"
            if [ $? -ne 0 ]; then
                echo -e "\nERROR: Download failed! Aborting..."
                rm -f "$WP/RastaMod69-clang.tar.gz"
                exit 1
            fi
            
            rm -rf clang && mkdir -p "$RC_DIR" && tar -xf "$WP/RastaMod69-clang.tar.gz" -C "$RC_DIR"
            if [ $? -ne 0 ]; then
                echo -e "\nERROR: Extraction failed! Aborting..."
                rm -f "$WP/RastaMod69-clang.tar.gz"
                exit 1
            fi
            
            # Clean up the temporary file
            rm -f "$WP/RastaMod69-clang.tar.gz"
            
            echo -e "\nINFO: RastaMod69 Clang successfully cloned to $RC_DIR"
        fi
    fi


    # Lolz Clang
    if [[ $1 = "lolz" ]]; then
        if ! [ -d "$LZ_DIR" ]; then
            echo -e "\nINFO: Lolz Clang not found! Cloning to $LZ_DIR..."
            if ! git clone -q --depth=1 $LZ_REPO $LZ_DIR; then
                echo -e "\nERROR: Cloning failed! Aborting..."
                exit 1
            fi
        fi
    fi

    # Clone gcc binutils if needed
    if [[ $1 = "aosp" ]] || [[ $1 = "sdclang" ]]; then
        if ! [ -d "$GCC_DIR" ]; then
            echo -e "\nINFO: GCC not found! Cloning to $GCC_DIR..."
            if ! git clone -q -b lineage-19.1 --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 $GCC_DIR; then
                echo -e "\nERROR: Cloning failed! Aborting..."
                exit 1
            fi
        fi

        if ! [ -d "$GCC64_DIR" ]; then
            echo -e "\nINFO: GCC64 not found! Cloning to $GCC64_DIR..."
            if ! git clone -q -b lineage-19.1 --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 $GCC64_DIR; then
                echo -e "\nERROR: Cloning failed! Aborting..."
                exit 1
            fi
        fi
    fi
}

prep_toolchain() {
    if [[ $1 = "aosp" ]]; then
        CLANG_DIR="$AC_DIR"
        CCARM64_PREFIX=aarch64-linux-android-
        CCARM_PREFIX=arm-linux-androideabi-
        echo -e "\nINFO: Using AOSP Clang..."
    elif [[ $1 = "sdclang" ]]; then
        CLANG_DIR="$SD_DIR/compiler"
        CCARM64_PREFIX=aarch64-linux-android-
        CCARM_PREFIX=arm-linux-androideabi-
        echo -e "\nINFO: Using Snapdragon Clang..."
    elif [[ $1 = "proton" ]]; then
        CLANG_DIR="$PC_DIR"
        CCARM64_PREFIX=aarch64-linux-gnu-
        CCARM_PREFIX=arm-linux-gnueabi-
        echo -e "\nINFO: Using Proton Clang..."
    elif [[ $1 = "rm69" ]]; then
        CLANG_DIR="$RC_DIR"
        CCARM64_PREFIX=aarch64-linux-gnu-
        CCARM_PREFIX=arm-linux-gnueabi-
        echo -e "\nINFO: Using RastaMod69 Clang..."
    elif [[ $1 = "lolz" ]]; then
        CLANG_DIR="$LZ_DIR"
        CCARM64_PREFIX=aarch64-linux-gnu-
        CCARM_PREFIX=arm-linux-gnueabi-
        echo -e "\nINFO: Using Lolz Clang..."
    fi

    ## Set PATH according to toolchain
    if [[ $1 = "sdclang" ]] || [[ $1 = "aosp" ]] ; then
        export PATH="${CLANG_DIR}/bin:${GCC64_DIR}/bin:${GCC_DIR}/bin:/usr/bin:${PATH}"
    else
        export PATH="${CLANG_DIR}/bin:${PATH}"
    fi

    KBUILD_COMPILER_STRING=$("$CLANG_DIR"/bin/clang -v 2>&1 | head -n 1 | sed 's/(https..*//' | sed 's/ version//')
    export KBUILD_COMPILER_STRING
}

## Pre-build dependencies
install_deps_deb
get_toolchain $CLANG_TYPE
prep_toolchain $CLANG_TYPE

## Telegram info variables

CAPTION_BUILD="Build info:
*Device*: \`${DEVICE} [${CODENAME}]\`
*Kernel Version*: \`${LINUX_VER}\`
*Compiler*: \`${KBUILD_COMPILER_STRING}\`
*Linker*: \`$("$CLANG_DIR"/bin/${LINKER} -v | head -n1 | sed 's/(compatible with [^)]*)//' |
            head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')\`
*Branch*: \`$(git rev-parse --abbrev-ref HEAD)\`
*Commit*: [($(git rev-parse HEAD | cut -c -7))]($(echo $KERNEL_URL)/commit/$(git rev-parse HEAD))
*Build type*: \`$BUILD_TYPE\`
*Clean build*: \`$( [ "$DO_CLEAN" -eq 1 ] && echo Yes || echo No )\`
"

# Functions to send file(s) via Telegram's BOT api.
tgs() {
    MD5=$(md5sum "$1" | cut -d' ' -f1)
    curl -fsSL -X POST -F document=@"$1" https://api.telegram.org/bot"${TELEGRAM_BOT_TOKEN}"/sendDocument \
        -F "chat_id=${TELEGRAM_CHAT_ID}" \
        -F "parse_mode=Markdown" \
        -F "disable_web_page_preview=true" \
        -F "caption=${CAPTION_BUILD}*MD5*: \`$MD5\`" &>/dev/null
}

prep_build() {
    ## Prepare ccache
    if [ "$USE_CCACHE" = "1" ]; then
        echo -e "\nINFO: Using ccache\n"
        if [ "$IS_GP" = "1" ]; then
            export CCACHE_DIR=$WP/.ccache
            ccache -M 10G
        else
            echo -e "INFO: Environment is not Gitpod, please make sure you setup your own ccache configuration!\n"
        fi
    fi

    # Show compiler information
    echo -e "\nINFO: Compiler information: $KBUILD_COMPILER_STRING\n"
}

build() {
    mkdir -p out
    make O=out ARCH=arm64 $DEFCONFIG 2>&1 | tee log.txt

    # Delete leftovers
    rm -f out/arch/arm64/boot/Image*
    rm -f out/arch/arm64/boot/dtbo*
    rm -f log.txt

    export LLVM=1 LLVM_IAS=1
    export ARCH=arm64

    if [ $DO_MENUCONFIG = "1" ]; then
        make O=out menuconfig
    fi

    ## Start the build
    echo -e "\nINFO: Starting compilation...\n"

    if [ $USE_CCACHE = "1" ]; then
        make -j$(nproc --all) O=out \
        CC="ccache clang" \
        CROSS_COMPILE=$CCARM64_PREFIX \
        CROSS_COMPILE_ARM32=$CCARM_PREFIX \
        CLANG_TRIPLE=aarch64-linux-gnu- \
        READELF=llvm-readelf \
        OBJSIZE=llvm-size \
        OBJDUMP=llvm-objdump \
        OBJCOPY=llvm-objcopy \
        STRIP=llvm-strip \
        NM=llvm-nm \
        AR=llvm-ar \
        HOSTAR=llvm-ar \
        HOSTAS=llvm-as \
        HOSTNM=llvm-nm \
        LD=ld.lld 2>&1 | tee log.txt
    else
        make -j$(nproc --all) O=out \
        CC="clang" \
        CROSS_COMPILE=$CCARM64_PREFIX \
        CROSS_COMPILE_ARM32=$CCARM_PREFIX \
        CLANG_TRIPLE=aarch64-linux-gnu- \
        READELF=llvm-readelf \
        OBJSIZE=llvm-size \
        OBJDUMP=llvm-objdump \
        OBJCOPY=llvm-objcopy \
        STRIP=llvm-strip \
        NM=llvm-nm \
        AR=llvm-ar \
        HOSTAR=llvm-ar \
        HOSTAS=llvm-as \
        HOSTNM=llvm-nm \
        LD=ld.lld 2>&1 | tee log.txt
    fi
}

post_build() {
    ## Check if the kernel binaries were built.
    if [ -f "$OUT_IMAGE" ] && [ -f "$OUT_DTBO" ]; then
        echo -e "\nINFO: Kernel compiled succesfully! Zipping up..."
    else
        echo -e "\nERROR: Kernel files not found! Compilation failed?"
        echo -e "\nINFO: Uploading log to oshi.at\n"
        curl -T log.txt oshi.at
        exit 1
    fi

    # If local AK3 copy exists, assume testing.
    if [ -d $AK3_DIR ]; then
        AK3_TEST=1
        echo -e "\nINFO: AK3_TEST flag set because local AnyKernel3 dir was found"
    else
        if ! git clone -q --depth=1 $AK3_URL $AK3_DIR; then
            echo -e "\nERROR: Failed to clone AnyKernel3!"
            exit 1
        fi
    fi

    ## Copy the built binaries
    cp $OUT_IMAGE $AK3_DIR
    cp $OUT_DTBO $AK3_DIR
    rm -f *zip

    ## Prepare kernel flashable zip
    cd $AK3_DIR
    git checkout $AK3_BRANCH &> /dev/null
    zip -r9 "$ZIP_PATH" * -x '*.git*' README.md *placeholder
    cd ..
    rm -rf $AK3_DIR
    echo -e "\nINFO: Completed in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
    echo "Zip: $ZIP_PATH"
    echo " "
    if [ "$AK3_TEST" = 1 ]; then
        echo -e "\nINFO: Skipping deletion of AnyKernel3 dir because test flag is set"
    else
        rm -rf $AK3_DIR
    fi
    cd $KDIR
}

upload() {
    if [[ "${DO_OSHI}" = "1" ]]; then
    echo -e "\nINFO: Uploading to oshi.at...\n"
    curl -T $ZIP_PATH oshi.at; echo
    fi

    if [[ "${DO_TG}" = "1" ]]; then
            echo -e "\nINFO: Uploading to Telegram...\n"
            tgs $ZIP_PATH
            echo "INFO: Done!"
    fi
    if [[ "${LOG_UPLOAD}" = "1" ]]; then
        echo -e "\nINFO: Uploading log to oshi.at\n"
        curl -T log.txt oshi.at
    fi
    # Delete any leftover zip files
    # rm -f $WP/FloppyKernel*zip
}

clean() {
    make O=out clean
    make O=out mrproper
}

clean_tmp() {
    echo -e "INFO: Cleaning after build..."
    rm -f $OUT_IMAGE
    rm -f $OUT_DTBO
}

## Run build
# Do a clean build?
if [[ $DO_CLEAN = "1" ]]; then
    clean
fi
prep_build
build
post_build
clean_tmp

upload
