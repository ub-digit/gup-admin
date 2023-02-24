/** GTM Container ID pattern. */
export declare const GTM_ID_PATTERN: RegExp;
/**
 * Assert that the given id is a valid GTM Container ID.
 *
 * Tested against pattern: `/^GTM-[0-9A-Z]+$/`.
 *
 * @param id A GTM Container ID.
 */
export declare function assertIsGtmId(id: string): asserts id;
