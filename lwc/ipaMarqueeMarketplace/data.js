/**
 * Shared Data Singleton Class
 */
class IpaMarqueeMarketplaceData {
  data = {}

  subscribers = {}

  uid = 0

  /**
   * subscribe to data changes
   *
   * @param {Function} fn callback function
   * @returns {Function} unsubscribe function
   */
  subscribe(fn) {
    this.uid += 1;
    const { uid } = this;
    this.subscribers[uid] = fn;
    fn(this.data);
    return () => {
      delete this.subscribers[uid];
    };
  }

  /**
   * set new marquee data
   * - notify subscribers
   *
   * @param {object} data marquee data
   */
  setData(data) {
    this.data = { ...data };
    Object.values(this.subscribers).forEach((fn) => {
      fn(this.data);
    });
  }
}
export default new IpaMarqueeMarketplaceData();