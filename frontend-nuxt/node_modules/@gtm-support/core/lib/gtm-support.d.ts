import type { DataLayerObject } from './data-layer-object';
import type { GtmIdContainer } from './gtm-container';
import type { GtmSupportOptions } from './options';
/**
 * Object definition for a track event.
 */
export interface TrackEventOptions {
    [key: string]: any;
    event?: string;
    category?: any;
    action?: any;
    label?: any;
    value?: any;
    noninteraction?: boolean;
}
/**
 * The GTM Support main class.
 */
export declare class GtmSupport {
    /** GTM Container ID. */
    readonly id: string | string[] | GtmIdContainer[];
    /** GTM Support Options. */
    readonly options: Omit<GtmSupportOptions, 'id'>;
    readonly scriptElements: HTMLScriptElement[];
    /**
     * Constructs a new `GtmSupport` instance.
     *
     * @param options Options.
     */
    constructor(options: GtmSupportOptions);
    /**
     * Whether the script is running in a browser or not.
     *
     * You can override this function if you need to.
     *
     * @returns `true` if the script runs in browser context.
     */
    isInBrowserContext: () => boolean;
    /**
     * Check if plugin is enabled.
     *
     * @returns `true` if the plugin is enabled, otherwise `false`.
     */
    enabled(): boolean;
    /**
     * Enable or disable plugin.
     *
     * When enabling with this function, the script will be attached to the `document` if:
     *
     * - the script runs in browser context
     * - the `document` doesn't have the script already attached
     * - the `loadScript` option is set to `true`
     *
     * @param enabled `true` to enable, `false` to disable. Default: `true`.
     * @param source The URL of the script, if it differs from the default. Default: 'https://www.googletagmanager.com/gtm.js'.
     */
    enable(enabled?: boolean, source?: string): void;
    /**
     * Check if plugin is in debug mode.
     *
     * @returns `true` if the plugin is in debug mode, otherwise `false`.
     */
    debugEnabled(): boolean;
    /**
     * Enable or disable debug mode.
     *
     * @param enable `true` to enable, `false` to disable.
     */
    debug(enable: boolean): void;
    /**
     * Returns the `window.dataLayer` array if the script is running in browser context and the plugin is enabled,
     * otherwise `false`.
     *
     * @returns The `window.dataLayer` if script is running in browser context and plugin is enabled, otherwise `false`.
     */
    dataLayer(): DataLayerObject[] | false;
    /**
     * Track a view event with `event: "content-view"`.
     *
     * The event will only be send if the script runs in browser context and the if plugin is enabled.
     *
     * If debug mode is enabled, a "Dispatching TrackView" is logged,
     * regardless of whether the plugin is enabled or the plugin is being executed in browser context.
     *
     * @param screenName Name of the screen passed as `"content-view-name"`.
     * @param path Path passed as `"content-name"`.
     * @param additionalEventData Additional data for the event object. `event`, `"content-name"` and `"content-view-name"` will always be overridden.
     */
    trackView(screenName: string, path: string, additionalEventData?: Record<string, any>): void;
    /**
     * Track an event.
     *
     * The event will only be send if the script runs in browser context and the if plugin is enabled.
     *
     * If debug mode is enabled, a "Dispatching event" is logged,
     * regardless of whether the plugin is enabled or the plugin is being executed in browser context.
     *
     * @param param0 Object that will be used for configuring the event object passed to GTM.
     * @param param0.event `event`, default to `"interaction"` when pushed to `window.dataLayer`.
     * @param param0.category Optional `category`, passed as `target`.
     * @param param0.action Optional `action`, passed as `action`.
     * @param param0.label Optional `label`, passed as `"target-properties"`.
     * @param param0.value Optional `value`, passed as `value`.
     * @param param0.noninteraction Optional `noninteraction`, passed as `"interaction-type"`.
     */
    trackEvent({ event, category, action, label, value, noninteraction, ...rest }?: TrackEventOptions): void;
}
