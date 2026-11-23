import { LightningElement, api } from 'lwc';

export default class Partnerexp1 extends LightningElement {
    @api reactAppUrl = '';
    @api frameHeight = 800;
    @api frameTitle = 'Partner experience';

    get appConfiguration() {
        const value = (this.reactAppUrl || '').trim();
        if (!value) {
            return {
                error: 'Set the React app URL in Experience Builder to the published HTTPS address accessible to your community users.'
            };
        }

        let url;
        try {
            url = new URL(value);
        } catch {
            return { error: 'The React app URL must be a valid absolute HTTPS URL.' };
        }

        if (url.protocol !== 'https:' || url.username || url.password) {
            return {
                error: 'Use an HTTPS URL without embedded credentials for the React app.'
            };
        }

        return { url: url.href };
    }

    get appUrl() {
        return this.appConfiguration.url;
    }

    get configurationError() {
        return this.appConfiguration.error;
    }

    get frameStyle() {
        const height = Number(this.frameHeight);
        return `height: ${Number.isInteger(height) && height >= 300 && height <= 2000 ? height : 800}px;`;
    }

    get accessibleTitle() {
        return (this.frameTitle || '').trim() || 'Partner experience';
    }
}