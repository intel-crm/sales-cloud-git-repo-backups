import { api, LightningElement, track } from 'lwc';
import userId from '@salesforce/user/Id';

// apex classes
import getMessage from '@salesforce/apex/MarketplaceMessagingController.getMessage';
import getUserName from '@salesforce/apex/MarketplaceMessagingController.getUserName';
import postMessage from '@salesforce/apex/MarketplaceMessagingController.postMessage';

// custom labels
import messageHistoryLabel from '@salesforce/label/c.PMP_Messaging_MessageHistory';
import postAMessageLabel from '@salesforce/label/c.PMP_Messaging_PostAMessage';
import sendLabel from '@salesforce/label/c.PMP_Messaging_Send';

/**
 * <h1>Ipa Messaging component</h1>
 * This is a chat/messaging component for communication between partners and platform admins.
 * <br>It requires a 'channel' - and can be 'partner', 'offering' or 'solution'
 * <br><br>
 * It connects to the <code>MarketplaceMessagingController</code> Apex class.
 *
 * @example
 * <!-- HTML component example -->
 * <c-ipa-messaging
 *    heading="Messages about Your Offering"
 *    channel="offering"
 *    record-id={recordId}>
 * </c-ipa-messaging>
 *
 * @class IpaMessaging
 * @augments LightningElement
 * @property {string} [heading] component heading (optional)
 * @property {string} channel connects to different channels depending on use case (`partner`, `offering`, `solution`)
 * @property {string} recordId the id for the relevant record
 */
export default class IpaMessaging extends LightningElement {
  /** custom labels:
   * "Message History" - PMP_Messaging_MessageHistory
   * "Post a message" (placeholder) - PMP_Messaging_PostAMessage
   * "Send" (send button) - PMP_Messaging_Send
   *
   * @type {{ messageHistory: string, postAMessage: string, send: string }}
   * @private
   */
  labels = {
    messageHistory: messageHistoryLabel,
    postAMessage: postAMessageLabel,
    send: sendLabel,
  }

  /**
   * Max Length for Message Input
   *
   * @type {number}
   * @private
   */
  messageMaxLength = 255;

  @api heading;

  @api channel = '';

  @api recordId;

  // tracked variables

  /** show loading spinner
   *
   * @type {boolean}
   * @private
   */
  showSpinner;

  /**
   * @typedef MarketplaceChatMessage
   * @property {string} userID user id
   * @property {string} type message type ('message', 'status')
   * @property {string} author text of author name
   * @property {string} timestamp ISO formatted datetime of message
   * @property {string} message text of message
   */

  /** list of messages (data)
   *
   * @type {MarketplaceChatMessage[]}
   * @private
   */
  @track messages = [];

  /** component collapses on mobile
   *
   * @type {boolean}
   * @private
   */
  collapsed;

  /** disables link if scrolled to the top
   *
   * @type {boolean}
   * @private
   */
  historyLinkEnabled;

  /** disables input if sending (posting a message)
   *
   * @type {boolean}
   * @private
   */
  sending;

  /** internal message variable
   *
   * @type {string}
   * @private
   */
  newMessage = '';

  /**
   * connected callback
   * gets messages and user name data
   *
   * @private
   */
  connectedCallback() {
    this.showSpinner = true;
    Promise.all([
      getUserName().then((author) => { this.author = author; }),
      getMessage({ recordId: this.recordId, channel: this.channel })
        .then((messages) => {
          this._scrollToEnd = true;
          this.messages = JSON.parse(messages) || [];
        }),
    ]).then(() => {
      this.showSpinner = false;
    });
  }

  /**
   * rendered callback
   * scrolls to end once messages are loaded
   *
   * @private
   */
  renderedCallback() {
    if (this._scrollToEnd) {
      this._scrollToEnd = false;
      this.scrollToEnd();
    }
  }

  /**
   * formats messages
   *
   * @returns {object[]} messages for template
   * @private
   */
  get formattedMessages() {
    return this.messages.map((msg, idx) => {
      const bound = msg.userID === userId ? 'outbound' : 'inbound';
      return {
        ...msg,
        formattedAuthor: msg.author,
        key: `msg-${idx}`,
        isStatus: msg.type === 'status',
        isMessage: msg.type === 'message',
        liClass: `chat-msg-li chat-msg-li-${bound} slds-chat-listitem slds-chat-listitem_${bound}`,
        textClass: `chat-msg-text chat-msg-txt-${bound} slds-chat-message__text slds-chat-message__text_${bound}`,
        delimeter: ', ',
      };
    });
  }

  /**
   * checks to see if input value is empty
   *
   * @returns {boolean} empty status
   * @private
   */
  get isNewMessageEmpty() {
    return this.newMessage === '';
  }

  /**
   * checks to see if message container is scrolled to the top
   *
   * @private
   */
  resetMessageHistoryLink() {
    const chatEl = this.template.querySelector('.chat-container');
    this.historyLinkEnabled = chatEl && chatEl.scrollTop !== 0;
  }

  /**
   * sends message to Apex
   *
   * @private
   */
  async send() {
    const messageData = {
      author: this.author,
      userID: userId,
      timestamp: new Date().toISOString(),
      message: this.newMessage,
      type: 'message',
      direction: 'outbound',
    };
    this.showSpinner = true;
    try {
      await postMessage({
        recordId: this.recordId,
        channel: this.channel,
        message: messageData,
      });
    } catch (err) {
      console.error('Error sending message to server.', err);
    }
    this.showSpinner = false;
    this.newMessage = '';
    this.messages = this.messages.concat(messageData);
    this._scrollToEnd = true;
  }

  /**
   * handles keydown event to set value
   * if "ENTER" key then message is sent
   *
   * @param {event} evt keydown event
   * @private
   */
  handleInputChange(evt) {
    this.newMessage = evt.currentTarget.value;
  }

  /**
   * handles keydown event to set value
   * if "ENTER" key then message is sent
   *
   * @param {event} evt keydown event
   * @private
   */
  handleInputKeydown(evt) {
    if (evt.key === 'Enter') {
      this.newMessage = evt.currentTarget.value;
      this.send();
    }
  }

  /**
   * handles send button click
   * sends message
   *
   * @private
   */
  handleSendClick() {
    this.send();
  }

  /**
   * handles scrolling - refreshes view to enable/disable "Message History" link
   *
   * @private
   */
  handleScroll() {
    if (!this._debounceScroll) {
      this.resetMessageHistoryLink();
    }
    clearTimeout(this._debounceScroll);
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this._debounceScroll = setTimeout(() => {
      this.resetMessageHistoryLink();
      this._debounceScroll = null;
    }, 80);
  }

  /**
   * handles toggling (click on chevron up/down) - for mobile view only
   *
   * @param {event} evt click event
   * @private
   */
  handleToggleOpen(evt) {
    evt.preventDefault();
    this.collapsed = !this.collapsed;
  }

  /**
   * scrolls ~1 page up in message history
   *
   * @param {event} evt click event
   * @private
   */
  handlePageUp(evt) {
    evt.preventDefault();
    const chatEl = this.template.querySelector('.chat-container');
    chatEl.scrollTop = Math.max(0, chatEl.scrollTop - chatEl.offsetHeight);
  }

  /**
   * scrolls to end of message history
   *
   * @private
   */
  scrollToEnd() {
    const chatEl = this.template.querySelector('.chat-container');
    if (!chatEl.style.scrollBehavior) {
      chatEl.style.scrollBehavior = 'auto'; // jump to bottom on first load
    }
    chatEl.scrollTop = chatEl.scrollHeight;
    chatEl.style.scrollBehavior = 'smooth';
  }
}