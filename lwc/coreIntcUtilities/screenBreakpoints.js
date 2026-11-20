/**
 * @typedef ScreenConfig
 * @property {string} mediaQuery media query for this screen size
 * @property {string} name name for screen size (ie. 'small' / 'large')
 * @property {string} [abbr] abbreviated name (ie. 'sm' / 'lg')
 * @property {boolean} [isMobile] true if screen is 'Mobile'
 * @property {boolean} [isTablet] true if screen is 'Tablet'
 * @property {boolean} [isDesktop] true if screen is 'Desktop'
 */

/**
 * Default Screen Sizes / Breakpoints
 *
 * @typedef ScreenConfig[]
 * @public
 */
export const DefaultScreenConfig = [
  {
    mediaQuery: '(max-width: 479px)',
    name: 'xs',
    isMobile: true,
  },
  {
    mediaQuery: '(min-width: 480px) and (max-width: 767px)',
    name: 'sm',
    isMobile: true,
  },
  {
    mediaQuery: '(min-width: 768px) and (max-width: 1023px)',
    name: 'md',
    isTablet: true,
  },
  {
    mediaQuery: '(min-width: 1024px) and (max-width: 1279px)',
    name: 'lg',
    isDesktop: true,
  },
  {
    mediaQuery: '(min-width: 1280px)',
    name: 'xl',
    isDesktop: true,
  },
];

/**
 * @class
 * @private
 */
class Screen {
  /**
   * class constructor
   *
   * @param {ScreenConfig} screen screen configuration object w/ media query breakpoints
   * @param {Function} fn first subscriber
   */
  constructor(screen, fn) {
    this.mediaQueryList = window.matchMedia(screen.mediaQuery);
    this.screen = screen;
    this.subscribers = [fn];
  }
}

/**
 * @type {object<string, Screen>} (key is mediaQuery)
 * @private
 */
const Screens = {};

/**
 * Screen Config Object
 *
 * @param {ScreenConfig[]} screens config for screen sizes
 * @param {Function} fn callback function
 * @returns {Function} unsubscribe function (ie. to be used in #disconnectedCallback)
 * @private
 */
export function subscribeToScreenChange(screens, fn) {
  const unsubscribeFunctions = screens.map((screen) => {
    const existingScreen = Screens[screen.mediaQuery];
    if (existingScreen) {
      const configMatch = Object.values(Screens).find((scr) => matchScreenConfig(screen, scr));
      if (configMatch) {
        throw new Error(
          `CoreIntcUtilities already has the existing mediaQuery ${screen.mediaQuery}. [Existing, New]`,
          configMatch.screen,
          existingScreen.screen,
        );
      }
      existingScreen.subscribers.push(fn);
    } else {
      Screens[screen.mediaQuery] = new Screen(screen, fn);
      Screens[screen.mediaQuery].mediaQueryList.addEventListener('change', handleMediaQueryChange);
    }

    const currentScreen = Screens[screen.mediaQuery];

    // invoke callback immediately to get initial value (current screen size)
    if (currentScreen.mediaQueryList.matches) {
      fn(screen);
    }

    return () => {
      currentScreen.subscribers.splice(currentScreen.subscribers.indexOf(fn), 1);
      // if no more subscribers, remove screen from mediaQueryListSubscriptions
      if (!currentScreen.subscribers.length) {
        currentScreen.mediaQueryList.removeEventListener('change', handleMediaQueryChange);
        delete Screens[screen.mediaQuery];
      }
    };
  });
  return () => {
    unsubscribeFunctions.forEach((unsubscribe) => unsubscribe());
  };
}

/**
 * Match Screen Config
 * - this will shallow compare screen configs... to avoid duplicates but allow for customization
 *
 * @param {ScreenConfig} screen1 first screen to compare
 * @param {ScreenConfig} screen2 second screen to compare
 * @returns {boolean} shallow compare equality
 * @private
 */
function matchScreenConfig(screen1, screen2) {
  return Object.keys(screen1).length === Object.keys(screen2).length
    && Object.keys(screen1).every((key) => screen1[key] === screen2[key]);
}

/**
 * handleMediaQueryChange function
 *
 * @param {event} evt change event
 * @private
 */
function handleMediaQueryChange(evt) {
  const { matches, media } = evt;
  // if media query matches, lookup matching screen configs, notify all subscribers
  if (matches) {
    const screen = Screens[media];
    screen.subscribers.forEach((subscriber) => {
      subscriber(screen.screen);
    });
  }
}