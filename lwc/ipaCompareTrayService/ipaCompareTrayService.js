import { handleError } from 'c/ipaErrorServiceMarketplace';

/**
 * Compare Tray Data Class (Singleton)
 *
 */
class IpaCompareTrayService {
  /**
   * capacity
   *
   * @type {number}
   */
  capacity = 4;

  /**
   * compare tray items
   *
   * @type {object[]}
   * @private
   */
  items = [];

  /**
   * status
   * - used for notification message
   *
   * @type {string}
   * @private
   */
  status = '';

  /**
   * subscriber list
   *
   * @type {object}
   * @private
   */
  subscribers = {};

  /**
   * UID to keep track of subscribers
   *
   * @type {number}
   * @private
   */
  subscriberIdx = 0;

  /** toggle item in tray
   *
   * @param {object} item product
   */
  toggleItem(item) {
    const idx = this.items.findIndex((i) => i.id === item.id);
    const items = [...this.items];
    // item is in tray, must be removed
    if (idx > -1) {
      items.splice(idx, 1);
    // !!! if tray is already at full capacity
    } else if (items.length === this.capacity) {
      this.status = 'FULL';
    // !!! if tray contains different categories
    } else if (items.some((i) => i.compareCategoryId !== item.compareCategoryId)) {
      this.status = 'CATEGORY_MISMATCH';
    // otherwise add item to tray
    } else {
      this.status = '';
      items.push(item);
    }
    this.updateTray(items);
  }

  /**
   * clears status
   *
   */
  clearStatus() {
    this.status = '';
    this.notify();
  }

  /**
   * clears status
   *
   */
  clearTray() {
    this.status = '';
    this.updateTray([]);
  }

  /**
   * Subscribe function
   *
   * @param {Function} callback callback function
   * @returns {Function} unsubscribe function
   */
  subscribe(callback) {
    this.subscriberIdx += 1;
    const uid = this.subscriberIdx;
    this.subscribers[uid] = callback;
    this.notify(uid);
    return () => {
      delete this.subscribers[uid];
    };
  }


  /**
   * Session storage key
   *
   * @type {string}
   * @private
   */
  SESSION_STORAGE_KEY = 'ipaCompareTray-cache';

  /**
   * constructor
   * loads items
   *
   * @private
   */
  constructor() {
    try {
      const itemsJSON = sessionStorage.getItem(this.SESSION_STORAGE_KEY);
      this.items = itemsJSON ? JSON.parse(itemsJSON) : [];
    } catch (err) {
      handleError('Problem with sessionStorage, might be disabled.', 'ipaCompareTrayService', 'console');
      this.items = [];
    }
  }

  /**
   * Updates Compare Tray
   * - stores in sessionStorage if available
   *
   * @param {object[]} items new compare tray items
   * @private
   */
  updateTray(items) {
    this.items = [...items];
    try {
      sessionStorage.setItem(this.SESSION_STORAGE_KEY, JSON.stringify(this.items));
    } catch (err) {
      handleError('Problem with sessionStorage, might be disabled.', 'ipaCompareTrayService', 'console');
    }
    this.notify();
  }

  /**
   * notifies subscribers
   * - default (all subscribers)
   * - reformats items for easy id lookup
   *
   * @param {number} [uid] optional uid
   * @private
   */
  notify(uid) {
    const subscribers = uid ? [this.subscribers[uid]] : Object.values(this.subscribers);
    const itemsObj = this.items.reduce((items, item) => ({ ...items, [item.id]: item }), {});
    const payload = {
      items: itemsObj,
      notification: this.status,
    };
    subscribers.forEach((subscriber) => {
      subscriber(payload);
    });
  }
}
export default new IpaCompareTrayService();