import { LightningElement, track, api } from 'lwc';

export default class customtoast extends LightningElement {

    @api
    message;
    @track
    title;
    @api
    type;

    @api
    show(message, type) {
        this.title = 'error';
        this.message = message;
        this.type = type || 'error';

        const toast = this.template.querySelector('.toast');
        toast.classList.toggle('toast_show');
        toast.classList.toggle('toast_hide');

        this.timer = setTimeout(() => {
            {
                toast.classList.toggle('toast_show');
                toast.classList.toggle('toast_hide');
            }
        }, 3000);
    }

    get notifyClasses() {
        return 'slds-notify slds-notify_toast slds-theme_${this.type}';
    }
    get iconName() {
        return 'utility:${this.type}';
    }
}