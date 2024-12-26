#include <linux/of.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/kernel.h>

static bool delete_fstabdt = true; // Default is true unless fstabdt_keep is present
module_param(delete_fstabdt, bool, 0444);

static int __init modify_fstab_entry(void)
{
	struct device_node *fstab_node, *vendor_node;
	struct property *prop;
	int ret;

	// Parse the kernel command line for "fstabdt_keep"
	if (strstr(saved_command_line, "fstabdt_keep")) {
		delete_fstabdt = false;
	}

	if (!delete_fstabdt) {
		pr_info("fstabdt_keep is present. Skipping modification.\n");
		return 0;
	}

	fstab_node = of_find_node_by_path("/firmware/android/fstab");
	if (!fstab_node) {
		pr_err("Failed to find fstab node\n");
		return -ENODEV;
	}

	vendor_node = of_get_child_by_name(fstab_node, "vendor");
	if (!vendor_node) {
		pr_err("Failed to find vendor node\n");
		return -ENODEV;
	}

	// Find the status property
	prop = of_find_property(vendor_node, "status", NULL);
	if (!prop) {
		pr_err("Failed to find status property\n");
		return -ENODEV;
	}

	// Remove the current status property
	of_remove_property(vendor_node, prop);

	// Add a new status property with the value "disabled"
	prop = kzalloc(sizeof(*prop), GFP_KERNEL);
	if (!prop) {
		pr_err("Failed to allocate memory for property\n");
		return -ENOMEM;
	}
	prop->name = "status";
	prop->length = sizeof("disabled");
	prop->value = kstrdup("disabled", GFP_KERNEL);
	if (!prop->value) {
		pr_err("Failed to allocate memory for property value\n");
		kfree(prop);
		return -ENOMEM;
	}
	ret = of_add_property(vendor_node, prop);
	if (ret) {
		pr_err("Failed to add new status property\n");
		kfree(prop->value);
		kfree(prop);
		return ret;
	}

	pr_info("Fstab entry modified successfully\n");
	return 0;
}

early_initcall(modify_fstab_entry);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Flopster101");
MODULE_DESCRIPTION("Small driver to disable the device-tree fstab for two-stage init ROMs.");
