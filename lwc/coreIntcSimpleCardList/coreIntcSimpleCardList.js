import { LightningElement, api } from 'lwc';

/**
 * A component for rendering a collection of {@link CoreIntcSimpleCard} components. The cards are displayed
 * in columns, with the number of columns determined by screen resolution. If the number of cards exceeds the number of columns,
 * cards are placed in a new row.
 *
 * ### Display Columns:
 * * For resolutions greater than 1023px, five columns are the default. This number can be
 *  changed using the <code>desktopCols</code> property.
 * * For resolutions greater than 766px and less than 1024px, two columns are used to display the cards.
 * * For resolutions below 767px, a single column is used to display the cards.
 *
 * ### Notes:
 * * The <code>cardTemplateType</code> property will affect the horizontal alignment of content within cards:
 *   * The "Icon Horizontal" and "Icon Body" settings will make content left aligned.
 *   * The "No Icon" and "Icon Vertical" settings will make content center aligned.
 * * For example cards in the <code>cardListData</code>, please see the {@link CoreIntcSimpleCard}.
 *
 * <div id="core-examples" sf-attr="c-coreintcsimplecardlist_coreintcsimplecardlist c-coreintclink_coreintclink">
 *  <demo-core-intc-simple-card-list show1="true" class="slds-scope" c-coreintcsimplecard_coreintcsimplecard></demo-core-intc-simple-card-list>
 *  <demo-core-intc-simple-card-list show2="true" class="slds-scope"
 *    c-coreintcsimplecard_coreintcsimplecardwithiconhorizontal></demo-core-intc-simple-card-list>
 *  <demo-core-intc-simple-card-list show3="true" class="slds-scope" c-coreintcsimplecard_coreintcsimplecardwithiconvertical></demo-core-intc-simple-card-list>
 *  <demo-core-intc-simple-card-list show4="true" class="slds-scope" c-coreintcsimplecard_coreintcsimplecardwithbody></demo-core-intc-simple-card-list>
 *  <demo-core-intc-simple-card-list show5="true" class="slds-scope" c-coreintcsimplecard_coreintcsimplecardwithiconvertical></demo-core-intc-simple-card-list>
 * </div>
 *
 * @example
 * <!-- HTML component example 1 -->
 * <!-- No icons -->
 * <c-core-intc-simple-card-list card-template-type="No Icon" card-list-data={cardData}></c-core-intc-simple-card-list>
 *
 * @example
 * <!-- HTML component example 2 -->
 * <!-- Horizontal icons -->
 * <c-core-intc-simple-card-list card-template-type="Icon Horizontal" card-list-data={cardData}></c-core-intc-simple-card-list>
 *
 * @example
 * <!-- HTML component example 3 -->
 * <!-- Vertical icons -->
 * <c-core-intc-simple-card-list card-template-type="Icon Vertical" card-list-data={cardData}></c-core-intc-simple-card-list>
 *
 * @example
 * <!-- HTML component example 4 -->
 * <!-- Icon Body -->
 * <c-core-intc-simple-card-list card-template-type="Icon Body" card-list-data={cardData}></c-core-intc-simple-card-list>
 *
 * @example
 * <!-- HTML component example 5 -->
 * <!-- Icon Vertical with large headings, gray theme, and 3 desktop columns-->
 * <c-core-intc-simple-card-list card-template-type="Icon Vertical" card-list-data={cardData}
 *  desktop-cols="3" large-heading="true" theme="gray"></c-core-intc-simple-card-list>
 *
 * @augments LightningElement
 * @property {string} [cardTemplateType="No Icon"] The card style to pass to the {@link CoreIntcSimpleCard} component. It can be 'No Icon',
 * 'Icon Horizontal', 'Icon Vertical', or 'Icon Body'.
 * @property {object[]} cardListData An array of {@link CoreCard} objects to be rendered by the {@link CoreIntcSimpleCard} component.
 * @property {number|string} [desktopCols=5] The number of columns to use when rendering the list in display resolutions above 1023px.
 * @property {string} [largeHeading=false] Indicates if the card title should be displayed in large font. Does not apply to the "Icon Body"
 * template when using linkData, which is always displayed in large font.
 * @property {string} [theme=default] Indicates the if the "default" or "gray" theme should be used.
 */
class CoreIntcSimpleCardList extends LightningElement {
  // ******* API variables - defined in class properties *******
  @api cardListData;

  @api cardTemplateType;

  @api desktopCols;

  @api largeHeading;

  @api theme = 'default';

  // Not defining type in JSDoc since it has a targetted use case for IPA
  @api type = 'default';
}
export default CoreIntcSimpleCardList;