import { LightningElement,api,track } from 'lwc';
export default class Sales_licenseCustomActions extends LightningElement {
		@api selectedRow;
		@track isDistributedDisabled = true;
		@track showProcessOption = false;
		@track isRed=false;
		connectedCallback(){
				const currentRow = JSON.parse(this.selectedRow);
				this.isDistributedDisabled = currentRow.isDistributedDisabled;
				this.showProcessOption = currentRow.showCreateOptionLicenseAction;
				this.isRed=currentRow.isRed;
		}
		
		fireDistribute(){
				const firedistributeEvent = new CustomEvent('firedistribute',{
						composed: true,
            bubbles: true,
            cancelable: true,
						detail: {
                selectedRow: this.selectedRow,
            },
				});
				this.dispatchEvent(firedistributeEvent);
		}
		
		fireProcess(){
				const fireprocessEvent = new CustomEvent('fireprocess',{
						composed: true,
            bubbles: true,
            cancelable: true,
						detail: {
                selectedRow: this.selectedRow,
            },
				});
				this.dispatchEvent(fireprocessEvent);
		}

		get buttonClass(){
			return this.isRed?'redColor':'greyColor';
		}
}