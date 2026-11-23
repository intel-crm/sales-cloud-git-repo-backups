import { LightningElement, wire } from 'lwc';
import {
  APPLICATION_SCOPE,
  MessageContext,
  subscribe,
  unsubscribe,
} from 'lightning/messageService';
import coreIntcToastMessages from '@salesforce/messageChannel/coreIntcToastMessages__c';


/**
 * Think about displaying multiple toasts (20+)
 * How do we handle toasts? Use this as a Message handler?
 */
class CoreIntcToast extends LightningElement {

  /**
   * Provides info about the components using the message channel.
   *
   * @type {object}
   * @private
   */
  @wire(MessageContext)
  messageContext;

  /**
   * List of toast messages
   *
   * @type {object[]}
   * @private
   */
  _toastMessages = [];

  /**
   * Subscription to the error message channel.
   *
   * @type {object}
   * @private
   */
  subscription;

  /**
   * Getter for toastMessages
   *
   * @type {string}
   * @private
   */
  get toastMessages() {
    return this._toastMessages.map((item, idx) => ({ idx, ...item }));
  }

  /**
   * Subscribes to core message channel
   *
   * @private
   */
  connectedCallback() {
    this.subscribeToMessageChannel();
  }

  /**
   * Removes subscription to message channel
   *
   * @private
   */
  disconnectedCallback() {
    this.unsubscribeToMessageChannel();
  }

  /**
   * Accessibility - focuses on first focusable element
   *
   * @private
   */
  focusFirstElement() {
    // add all the elements inside modal which you want to make focusable
    const focusableElements = 'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])';
    const firstFocusableElement = this.template.querySelectorAll(focusableElements)[0]; // get first element to be focused inside modal
    if (firstFocusableElement) {
      firstFocusableElement.focus(); // Focus on first focusableElement
    }
  }

  /**
   * Subscribe to the error message channel and sets the handler.
   *
   * @private
   */
  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        coreIntcToastMessages,
        (message) => this.handleMessage(message),
        { scope: APPLICATION_SCOPE },
      );
    }
  }

  /**
   * Unsubscribes to message channel.
   *
   * @private
   */
  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  /**
   * Displays received message as a toast
   *
   * @param {object} data Message data to display.
   * @private
   */
  handleMessage(data) {
    const message = {};
    if (data.message) {
      message.messageContent = data.message;
    }
    if (data.id) {
      message.id = data.id;
    }
    if (data.displayToast !== null) {
      if (data.displayToast) {
        // Add toast
        this._toastMessages.push(message);
        this._toastMessages = [...this._toastMessages];
        if (this._toastMessages.length === 1) {
          this.focusFirstElement();
        }
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
          const ind = this._toastMessages.findIndex((element) => element.id === message.id);
          if (ind !== -1) {
            this._toastMessages.splice(ind, 1);
            this._toastMessages = [...this._toastMessages];
          }
        }, 10000);
      } else {
        // Find toast with the id and remove the toast
        const ind = this._toastMessages.findIndex((element) => element.id === message.id);
        this._toastMessages.splice(ind, 1);
        this._toastMessages = [...this._toastMessages];
      }
    }
  }

  /**
   * Closes toast
   *
   * @param {object} evt Event object
   * @private
   */
  closeToast(evt) {
    const ind = evt.currentTarget.getAttribute('data-idx');
    this._toastMessages.splice(ind, 1);
    this._toastMessages = [...this._toastMessages];
  }
}
export default CoreIntcToast;