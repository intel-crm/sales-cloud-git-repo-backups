import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class PCC_RedirectionOfOldPortal extends LightningElement {
    redirectUrl;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        if (currentPageReference) {
            const url = new URL(window.location.href);
            const id = url.searchParams.get('id');

            // Check if the current URL contains the term 'DDR'
            if (url.href.includes('DDR')) {
                // Construct the redirection URL
                this.redirectUrl = '/partneradmin/s/core-design-registration/DDR/' + id; // Add your path here
            } else {
                // Handle the case when 'DDR' is not present in the URL
                console.log("The term 'DDR' is not present in the URL. No redirection.");
            }
        }
    }

    renderedCallback() {
        // Check if the redirection URL is set
        if (this.redirectUrl) {
            // Redirect to the constructed URL
            window.location.href = this.redirectUrl;
        }
    }
}