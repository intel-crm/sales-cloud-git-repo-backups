import { LightningElement, api, wire } from 'lwc';
import evaluateVisibilityCriteria from '@salesforce/apex/Core_MDF_GetObjectDetails.evaluateVisibilityCriteria';
import getLabelValue from '@salesforce/apex/Core_MDF_GetObjectDetails.getLabelValue';

export default class Core_MDF_staticTextDisplay extends LightningElement {
    @api textContent;
    @api backgroundColor = '#ffffff';
    @api textColor = '#000000';
    @api fontSize = '14';
    @api textAlign = 'left';
    @api fontWeight = 'normal';
    @api showIcon = false;
    @api iconName = 'utility:info';
    @api iconSize = 'x-small';
    @api iconVariant = 'neutral';
    @api iconPosition = 'left';
    @api iconMargin = '6';
    @api visibilityCriteria;
    @api recordId;
    isVisible = true;
    isLoading = false;
    labelValue ='';

    @wire(evaluateVisibilityCriteria, { 
        recordId: '$recordId', 
        criteria: '$visibilityCriteria' 
    })
    wiredVisibilityEvaluation({ error, data }) {
        this.isLoading = false;
        if (data !== undefined) {
            this.isVisible = data;
        } else if (error) {
            this.isVisible = true;
        }
    }

    connectedCallback() {
        if (!this.visibilityCriteria || !this.recordId) {
            this.isVisible = true;
        } else {
            this.isLoading = true;
        }
    }

    @wire(getLabelValue, { labelName: '$textContent' })
    wiredLabel({ data, error }) {
        if (data) {
            this.labelValue = data;
        }
        else if (error) {
            this.labelValue = '';
        }
    }

    get displayText() {
        return this.labelValue || this.textContent || '';
    }

    get containerStyles() {

        const flexDirection = this.iconPosition === 'top' || this.iconPosition === 'bottom' ? 'column' : 'row';
        const flexDirectionValue = this.iconPosition === 'right' || this.iconPosition === 'bottom' ? (flexDirection === 'column' ? 'column-reverse' : 'row-reverse') : flexDirection;
        let alignItems = 'flex-start';
        let justifyContent = 'flex-start';
        if (this.iconPosition === 'top' || this.iconPosition === 'bottom') {
            alignItems = 'center';
            justifyContent = 'center';
        } else {
            switch(this.textAlign) {
                case 'center':
                    justifyContent = 'center';
                    break;
                case 'right':
                    justifyContent = 'flex-end';
                    break;
                default:
                    justifyContent = 'flex-start';
            }
        }

        return `
            background-color: ${this.backgroundColor};
            color: ${this.textColor};
            font-size: ${this.fontSize}px;
            text-align: ${this.textAlign};
            font-weight: ${this.fontWeight};
            display: flex;
            align-items: ${alignItems};
            justify-content: ${justifyContent};
            flex-direction: ${flexDirectionValue};
            flex: 1;
            gap: ${this.showIcon ? this.iconMargin + 'px' : '0px'};
        `;
    }

    get iconClass() {
        return `icon-${this.iconPosition} align-with-text`;
    }

}