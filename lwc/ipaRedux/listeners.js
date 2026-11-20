/* This includes any global listeners that result in dispatches */

import { breakpoints } from './reducers/ui';

export default store => {

    breakpoints.forEach(breakpoint => {
        window.matchMedia(breakpoint.mediaQuery).addListener(function(e) {
            if (e.matches) {
                store.dispatch('changeUI', { breakpoint });
                /* Backwards Compatibility TODO - point everything to UI instead of settings */
                store.dispatch('changeSettings', {
                    currentScreenSize: breakpoint.isMobile ? 'mobile' : 'desktop',
                    currentSldsBreakPoint: breakpoint.name
                });
            }
        });
    });

}