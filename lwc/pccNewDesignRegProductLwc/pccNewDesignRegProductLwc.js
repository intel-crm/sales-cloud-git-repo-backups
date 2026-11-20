import { LightningElement, api } from 'lwc';
import getPriceForProduct from '@salesforce/apex/PCC_NewDesignRegProductCntrl.getPriceForProduct';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import MMID_SWITCH from '@salesforce/label/c.DDR_MMID_switch';

export default class PccNewDesignRegProductLwc extends LightningElement {
    @api drId;
    isLoading = true;
    displaySave = false;
    responseResult;
    targetResalePrice;
    sdp;
    rcp;
    ddiEligible;
    expDate;
    ddiFocused;

    // Getter to determine the message based on custom label
    get productSelectionMessage() {
        if (MMID_SWITCH?.toLowerCase() === 'true') {
            return 'Please select Product or MMID or Old MMID or Ordering code';
        } else {
            return 'Please select Product or MMID or Ordering code';
        }
    }

    async handleProductChange(event) {
        const prodId = event.target.value;

        if (prodId) {
            this.isLoading = true;
            try {
                const result = await getPriceForProduct({ productId: prodId, designRegId: this.drId });
                console.log('result is product', result);
                this.responseResult = result;

                if (this.responseResult && this.responseResult.priceType) {
                    if (this.responseResult.priceType === 'SDP') {
                        this.targetResalePrice = result.sdp;
                    } else if (this.responseResult.priceType === 'RCP') {
                        this.targetResalePrice = result.rcp;
                    }
                    this.sdp = result.sdp;
                    this.rcp = result.rcp;
                }
                this.isLoading = false;
            } catch (e) {
                this.isLoading = false;
                console.log('error', e);
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: e.body.message,
                    variant: 'error'
                });
                this.dispatchEvent(event);
            }
        }
    }

    async handleMMIDChange(event) {
        const mmIdRed = event.target.value;

        if (mmIdRed) {
            this.isLoading = true;
            const result = await getPriceForProduct({ productMappingRecId: mmIdRed, designRegId: this.drId });
            console.log('result is mmid', result);
            this.responseResult = result;

            if (this.responseResult && this.responseResult.priceType) {
                if (this.responseResult.priceType === 'SDP') {
                    this.targetResalePrice = result.sdp;
                } else if (this.responseResult.priceType === 'RCP') {
                    this.targetResalePrice = result.rcp;
                }
                this.sdp = result.sdp;
                this.rcp = result.rcp;
            }

            // Set Payment Eligibility Info
            if (this.responseResult && this.responseResult.ddiEligible) {
                this.ddiEligible = result.ddiEligible;
                this.expDate = result.expDate;
                this.ddiFocused = result.ddiFocused;
            }

            this.isLoading = false;
        }
    }

    handleSuccess() {
        this.isLoading = false;
        this.dispatchEvent(new CustomEvent('closequickmodal'));
    }

    handleSubmit() {
        this.isLoading = true;
    }

    handleLoad() {
        this.displaySave = true;
        this.isLoading = false;
    }

    handleError(event) {
        this.isLoading = false;
        const titleMsg = event.detail.detail ? 'Error Occurred' : 'Review the errors on this page';
        const evt = new ShowToastEvent({
            title: titleMsg,
            message: event.detail.detail,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }

    handleClosePopup() {
        this.dispatchEvent(new CustomEvent('closequickmodal'));
    }
}