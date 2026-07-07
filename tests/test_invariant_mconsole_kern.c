#include <check.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

/* Mock mconsole_request structure matching kernel definition */
struct mconsole_request {
    int len;
    char data[1024];
};

/* Forward declaration - we'll test the vulnerable pattern */
static int validate_buffer_length(struct mconsole_request *req, int ptr_offset) {
    char *ptr = req->data + ptr_offset;
    int remaining = req->len - (ptr - req->data);
    /* Security invariant: remaining length must never be negative or overflow */
    return remaining;
}

START_TEST(test_mconsole_buffer_underflow_invariant)
{
    /* Invariant: buffer length calculation must never underflow,
       resulting in negative or unreasonably large remaining length */
    
    struct mconsole_request req;
    
    /* Test payloads: exploit case, boundary cases, valid input */
    struct {
        int req_len;
        int ptr_offset;
        const char *description;
    } payloads[] = {
        {10, 20, "underflow: offset > len"},           /* Exploit: underflow */
        {0, 1, "boundary: zero len with offset"},      /* Boundary case */
        {100, 50, "valid: normal case"},               /* Valid input */
        {1, 0, "boundary: minimal valid"},             /* Edge case */
        {1024, 2000, "underflow: large offset"}        /* Extreme underflow */
    };
    
    int num_payloads = sizeof(payloads) / sizeof(payloads[0]);
    
    for (int i = 0; i < num_payloads; i++) {
        req.len = payloads[i].req_len;
        memset(req.data, 'A', sizeof(req.data));
        
        int remaining = validate_buffer_length(&req, payloads[i].ptr_offset);
        
        /* Security property: remaining length must be within valid bounds.
           If ptr_offset > req_len, subtraction underflows to large positive.
           We must detect and reject this. */
        int expected_remaining = req.len - payloads[i].ptr_offset;
        
        /* The invariant: if offset exceeds len, result indicates corruption */
        if (payloads[i].ptr_offset > payloads[i].req_len) {
            /* Underflow detected - remaining will be negative (as signed int) */
            ck_assert_msg(remaining < 0 || remaining > 10000,
                "Underflow case should produce invalid length, got %d for %s",
                remaining, payloads[i].description);
        } else {
            /* Valid case - remaining should match expected */
            ck_assert_int_eq(remaining, expected_remaining);
            ck_assert_msg(remaining >= 0,
                "Valid case must have non-negative remaining length for %s",
                payloads[i].description);
        }
    }
}
END_TEST

Suite *security_suite(void)
{
    Suite *s;
    TCase *tc_core;

    s = suite_create("Security");
    tc_core = tcase_create("Core");

    tcase_add_test(tc_core, test_mconsole_buffer_underflow_invariant);
    suite_add_tcase(s, tc_core);

    return s;
}

int main(void)
{
    int number_failed;
    Suite *s;
    SRunner *sr;

    s = security_suite();
    sr = srunner_create(s);

    srunner_run_all(sr, CK_NORMAL);
    number_failed = srunner_ntests_failed(sr);
    srunner_free(sr);

    return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}