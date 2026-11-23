import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import DOCEBO_KERNEL from '@salesforce/resourceUrl/DoceboKernel';
import getDoceboAccessToken from '@salesforce/apex/PMP_DoceboAuthController.getDoceboAccessToken';

export default class DoceboEmbed extends LightningElement {

    initialized = false;
    widgetCreated = false;

    renderedCallback() {

        if (this.initialized) {
            return;
        }

        const container = this.template.querySelector('.docebo-container');

        if (!container) {
            console.error('Docebo container not found');
            return;
        }

        this.initialized = true;

        console.log('DOCEBO LWC INITIALIZATION START');

        this.initializeDocebo();
    }

    async initializeDocebo() {

        try {

            console.log('STEP 1 - Loading Docebo kernel');

            await loadScript(this, DOCEBO_KERNEL);

            console.log('STEP 1 COMPLETE - Kernel loaded');

            console.log('DSDK:', window.DSDK);

            if (typeof window.DSDK === 'undefined') {
                throw new Error('DSDK is undefined after loading Docebo kernel.');
            }

            console.log('STEP 2 - Checking AbortController');

            console.log(
                'AbortController:',
                window.AbortController
            );

            console.log(
                'AbortSignal:',
                window.AbortSignal
            );

            if (window.AbortController) {

                const controller =
                    new window.AbortController();

                console.log(
                    'AbortController test:',
                    controller
                );

                console.log(
                    'AbortSignal test:',
                    controller.signal
                );

                console.log(
                    'AbortSignal instanceof AbortSignal:',
                    controller.signal instanceof window.AbortSignal
                );
            }

            console.log('STEP 3 - Configuring token provider');

            const renewToken = async () => {

                console.log('renewToken() called');

                const token =
                    await getDoceboAccessToken();

                if (!token) {
                    throw new Error(
                        'Apex returned an empty Docebo access token.'
                    );
                }

                console.log(
                    'Docebo access token received'
                );

                console.log(
                    'Token length:',
                    token.length
                );

                return token;
            };

            window.DSDK
                .kernel()
                .setTokenProvider(renewToken);

            console.log(
                'STEP 3 COMPLETE - Token provider configured'
            );

            console.log(
                'STEP 4 - Starting Docebo kernel'
            );

            const kernel =
                window.DSDK.kernel();

            kernel.start({
                domain:
                    'https://intelexternalsandbox.docebosaas.com',
                language:
                    'en-US'
            });

            console.log(
                'STEP 4 COMPLETE - Kernel start called'
            );

            console.log(
                'Custom element:',
                window.customElements.get(
                    'dcbo-my-courses-and-lp'
                )
            );

            this.createWidget();

        } catch (error) {

            console.error(
                'DOCEBO INITIALIZATION ERROR:',
                error
            );

            console.error(
                'ERROR MESSAGE:',
                error?.message
            );

            console.error(
                'ERROR STACK:',
                error?.stack
            );
        }
    }

    createWidget() {

        if (this.widgetCreated) {
            return;
        }

        const container =
            this.template.querySelector(
                '.docebo-container'
            );

        if (!container) {

            console.error(
                'Docebo container not found'
            );

            return;
        }

        const existingWidget =
            container.querySelector(
                '#my-courses-widget'
            );

        if (existingWidget) {

            console.log(
                'Docebo widget already exists'
            );

            this.widgetCreated = true;

            return;
        }

        console.log(
            'STEP 5 - Creating Docebo widget'
        );

        const widget =
            document.createElement(
                'dcbo-my-courses-and-lp'
            );

        widget.id =
            'my-courses-widget';

        container.appendChild(widget);

        this.widgetCreated = true;

        console.log(
            'STEP 5 COMPLETE - Widget appended'
        );

        console.log(
            'Widget:',
            widget
        );

        console.log(
            'Widget tag:',
            widget.tagName
        );

        setTimeout(() => {

            console.log(
                'DOCEBO WIDGET RENDER CHECK'
            );

            console.log(
                'Widget:',
                widget
            );

            console.log(
                'Widget height:',
                widget.offsetHeight
            );

            console.log(
                'Widget width:',
                widget.offsetWidth
            );

        }, 5000);
    }
}