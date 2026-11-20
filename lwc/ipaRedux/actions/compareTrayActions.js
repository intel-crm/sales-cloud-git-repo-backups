/** {@link Redux.Action Redux Actions} for the {@link ipaRedux Marketplace Redux Store}
 * <h4>{@link module:Actions Marketplace Actions}</h4>
 * <h2>Compare Tray Actions</h2>
 * <br>
 * Note: Compare Tray keeps track of separate trays <i>per Category</i>
 * @redux
 * @reduxActionScope @COMPARE_TRAY
 * @module Actions/CompareTray
 */
export default {

    /**
     * Clears compare tray (either specific category or all)
     * @function @COMPARE_TRAY/clear
     * @param {object} params
     * @param {string} params.categoryId Category Id for the category to clear (if no ID given, it will clear all category trays)
     * @example
     * import { dispatch } from 'c/ipaRedux';
     *
     * dispatch('@COMPARE_TRAY/clear', { categoryId: 'XXX234' })
     * @memberof module:Actions/CompareTray
    */

    /**
     * Clears current compare tray notification
     * @function @COMPARE_TRAY/clearNotification
     * @example
     * import { dispatch } from 'c/ipaRedux';
     *
     * dispatch('@COMPARE_TRAY/clearNotification')
     * @memberof module:Actions/CompareTray
    */

    /**
     * Sets a compare tray notification
     * @function @COMPARE_TRAY/notification
     * @param {object} params
     * @param {string} params.msg The message for the notification within the compare tray (ie. "Compare Tray Full")
     * @example
     * import { dispatch } from 'c/ipaRedux';
     *
     * dispatch('@COMPARE_TRAY/notification', { msg: 'Max capacity' })
     * @memberof module:Actions/CompareTray
    */

    /**
     * Toggles compare tray item
     * @function @COMPARE_TRAY/toggleItem
     * @param {object} params
     * @param {Product} params.item the product object associated with the card, including the following <b>required</b> attributes:<ul><li>id</li><li>imageUrl</li><li>title</li><li>compareCategoryId</li></ul><i><cody>compareCategoryId</code> corresponds to the second level category associated with the product (ie. Compoonent -> <b>Board</b>)<br><i>NOTE: only <code>id</code> is required to remove an item</i>
     * @example
     * import { dispatch } from 'c/ipaRedux';
     *
     * dispatch('@COMPARE_TRAY/toggleItem', { item: ... })
     * @memberof module:Actions/CompareTray
    */

};