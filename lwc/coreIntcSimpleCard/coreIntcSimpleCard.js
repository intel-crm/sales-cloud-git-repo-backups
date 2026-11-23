import { LightningElement, api } from 'lwc';

// Templates
import simpleCardNoIcon from './coreIntcSimpleCard.html';
import simpleCardWithIconVertical from './coreIntcSimpleCardWithIconVertical.html';
import simpleCardWithIconHorizontal from './coreIntcSimpleCardWithIconHorizontal.html';
import simpleCardWithBody from './coreIntcSimpleCardWithBody.html';



/**
 * A component for displaying links and icons in a card type format. This component displays a single card, and is used by
 * the {@link CoreIntcSimpleCardList} for displaying multiple cards. Four different templates
 * are available to control the display of content.
 *
 * ### Templates:
 * * No Icon: The link is displayed by itself.
 * * Icon Horizontal: The icon is displayed to the left of the link.
 * * Icon Vertical: The icon is displayed above the link.
 * * Icon Body: The title and icon are displayed above the description and link. The description and link can be replaced with
 *    custom content using the "body" slot.
 *
 * ### Notes:
 * * The card will expand to fit its parent container.
 * * The <code>cardTemplateType</code> property will affect the horizontal alignment of content within cards:
 *   * The "Icon Horizontal" and "Icon Body" settings will make content left aligned.
 *   * The "No Icon" and "Icon Vertical" settings will make content center aligned.
 * * Only one of <code>icon</code>, <code>sfIcon</code>, <code>imageUrl</code>, or <code>svgIconUrl</code> should be set in
 *  the <code>card</code> properties.
 *
 * <div id="core-examples" sf-attr="c-coreintclink_coreintclink">
 *  <demo-core-intc-simple-card show1="true"></demo-core-intc-simple-card>
 *  <demo-core-intc-simple-card show2="true"></demo-core-intc-simple-card>
 *  <demo-core-intc-simple-card show3="true"></demo-core-intc-simple-card>
 *  <demo-core-intc-simple-card show4="true"></demo-core-intc-simple-card>
 *  <demo-core-intc-simple-card show5="true"></demo-core-intc-simple-card>
 * </div>
 *
 * @example
 * // JavaScript component example 1 - using sfIcon
 * // Note that description is ignored by all templates except "Icon Body", and the icon is ignored in the "No Icon" template.
 * card1 = {
 *   description: 'Card 1 Description',
 *   key: 1,
 *   linkData: {
 *     externalUrl: 'https://www.intel.com',
 *     label: 'Intel',
 *   },
 *   sfIcon: 'utility:answer',
 *   title: 'Card 1 Title',
 * };
 *
 * @example
 * <!-- HTML component example 1 -->
 * <!-- "Icon Horizontal" cardTemplateType using sfIcon -->
 * <c-core-intc-simple-card card={card1} card-template-type="Icon Horizontal"></c-core-intc-simple-card>
 *
 * <!-- "Icon Vertical" cardTemplateType using sfIcon -->
 * <c-core-intc-simple-card card={card1} card-template-type="Icon Vertical"></c-core-intc-simple-card>
 *
 * <!-- "Icon Body" cardTemplateType using sfIcon -->
 * <c-core-intc-simple-card card={card1} card-template-type="Icon Body"></c-core-intc-simple-card>
 *
 * @example
 * // JavaScript component example 2 - using icon
 * card1 = {
 *   description: 'Card 2 Description',
 *   key: 2,
 *   linkData: {
 *     externalUrl: 'https://www.intel.com',
 *     label: 'Intel',
 *   },
 *   icon: 'fa-mail-1',
 *   title: 'Card 2 Title',
 * };
 *
 * @example
 * <!-- HTML component example 2 -->
 * <!-- "Icon Horizontal" cardTemplateType using icon -->
 * <c-core-intc-simple-card card={card2} card-template-type="Icon Horizontal"></c-core-intc-simple-card>
 *
 * <!-- "Icon Vertical" cardTemplateType using icon -->
 * <c-core-intc-simple-card card={card2} card-template-type="Icon Vertical"></c-core-intc-simple-card>
 *
 * <!-- "Icon Body" cardTemplateType using icon -->
 * <c-core-intc-simple-card card={card2} card-template-type="Icon Body"></c-core-intc-simple-card>
 *
 * @example
 * // JavaScript component example 3 - using svgIconUrl
 * card1 = {
 *   description: 'Card 3 Description',
 *   key: 3,
 *   linkData: {
 *     externalUrl: 'https://www.intel.com',
 *     label: 'Intel',
 *   },
 *   svgIconUrl: 'Enthusiast_PC.svg',
 *   title: 'Card 3 Title',
 * };
 *
 * @example
 * <!-- HTML component example 3 -->
 * <!-- "Icon Horizontal" cardTemplateType using svgIconUrl -->
 * <c-core-intc-simple-card card={card3} card-template-type="Icon Horizontal"></c-core-intc-simple-card>
 *
 * <!-- "Icon Vertical" cardTemplateType using svgIconUrl -->
 * <c-core-intc-simple-card card={card3} card-template-type="Icon Vertical"></c-core-intc-simple-card>
 *
 * <!-- "Icon Body" cardTemplateType using svgIconUrl -->
 * <c-core-intc-simple-card card={card3} card-template-type="Icon Body"></c-core-intc-simple-card>
 *
 * @example
 * // JavaScript component example 4 - using imageUrl
 * card1 = {
 *   description: 'Card 4 Description',
 *   key: 4,
 *   linkData: {
 *     externalUrl: 'https://www.intel.com',
 *     label: 'Intel',
 *   },
 *   imageUrl: 'Xeon.png',
 *   title: 'Card 4 Title',
 * };
 *
 * @example
 * <!-- HTML component example 4 -->
 * <!-- "Icon Horizontal" cardTemplateType using imageUrl -->
 * <c-core-intc-simple-card card={card4} card-template-type="Icon Horizontal"></c-core-intc-simple-card>
 *
 * <!-- "Icon Vertical" cardTemplateType using imageUrl -->
 * <c-core-intc-simple-card card={card4} card-template-type="Icon Vertical"></c-core-intc-simple-card>
 *
 * <!-- "Icon Body" cardTemplateType using imageUrl -->
 * <c-core-intc-simple-card card={card4} card-template-type="Icon Body"></c-core-intc-simple-card>
 *
 * @example
 * // JavaScript component example 5 - using sfIcon
 * card5 = {
 *   description: 'Card 5 Description',
 *   key: 5,
 *   linkData: {
 *     externalUrl: 'https://www.intel.com',
 *     label: 'Intel',
 *   },
 *   sfIcon: 'utility:answer',
 *   title: 'Card 5 Title',
 * };
 *
 * @example
 * <!-- HTML component example 5 -->
 * <!-- "No Icon" cardTemplateType -->
 * <c-core-intc-simple-card card={card5} card-template-type="No Icon"></c-core-intc-simple-card>
 *
 * <!-- "Icon Body" cardTemplateType with custom content -->
 * <c-core-intc-simple-card card={card5} card-template-type="Icon Body">
 *  <div slot="body">Custom Content Here</div>
 * </c-core-intc-simple-card>
 *
 * <!-- "Icon Vertical" cardTemplateType using sfIcon and largeHeading -->
 * <c-core-intc-simple-card card={card5} card-template-type="Icon Vertical"></c-core-intc-simple-card>
 *
 * <!-- "Icon Vertical" cardTemplateType using sfIcon and gray theme -->
 * <c-core-intc-simple-card card={card5} card-template-type="Icon Vertical"></c-core-intc-simple-card>
 *
 *
 * @augments LightningElement
 * @property {CoreCard} card The card data to be displayed.
 * @property {string} [cardTemplateType=No Icon] The card template for the component. It can be 'No Icon',
 * 'Icon Horizontal', 'Icon Vertical', or 'Icon Body'.
 * @property {string} [largeHeading=false] Indicates if the card title should be displayed in large font. Does not apply
 * to the "Icon Body" template when using linkData, which is always displayed in large font.
 * @property {string} [theme=default] Indicates the if the "default" or "gray" theme should be used.
 */
class CoreIntcSimpleCard extends LightningElement {
  // ******* API variables - defined in class properties *******
  @api cardTemplateType;

  @api card = {};

  @api theme = 'default';

  @api largeHeading;

  // Not defining type in JSDoc since it has a targetted use case for IPA
  @api type = 'default';



  // ******* Functions ********
  /**
   * Lifecycle hook called when rendering the card. Returns the template to use to render the card.
   *
   * @returns {object} The template to use when rendering the card.
   * @private
   */
  render() {
    switch (true) {
      case this.cardTemplateType === 'No Icon':
        return simpleCardNoIcon;
      case this.cardTemplateType === 'Icon Horizontal':
        return simpleCardWithIconHorizontal;
      case this.cardTemplateType === 'Icon Vertical':
        return simpleCardWithIconVertical;
      case this.cardTemplateType === 'Icon Body':
        return simpleCardWithBody;
      default:
        return simpleCardNoIcon;
    }
  }



  /**
   * Gets the CSS classes used for the icon.
   *
   * @returns {string} The CSS classes to use for a Font Awesome icon.
   * @private
   */
  get iconFaClass() {
    return `intel-icon ${this.card.icon}`;
  }



  /**
   * Gets an object with properties to indicate CSS class names for the container and the title.
   *
   * @returns {object} An object with properties containing CSS class names for the container and the title.
   * @private
   */
  get classes() {
    return {
      containerClass: `core-card-container theme-${this.theme} type-${this.type}`,
      titleClass: [
        this.type === 'contact-card' ? 'truncate-4' : '',
        this.largeHeading ? '' : 'p',
        this.theme === 'gray' ? '' : 'color-blue',
        'h4',
      ].join(' '),
    };
  }



  /**
   * Gets an object with properties incidcating if the card has link data and/or a description.
   *
   * @returns {object} An object indicating if the card has link data and/or a description.
   * @private
   */
  get ifs() {
    return {
      hasLinkData: this.card && this.card.linkData && Object.keys(this.card.linkData).length > 0,
      hasDescription: this.card && this.card.description,
    };
  }
}
export default CoreIntcSimpleCard;

// Note: leaving svgIcon out of CoreCard since it does not appear to be used.
/**
 * Represents a card to be displayed by the <a href="CoreIntcSimpleCard.html">CoreIntcSimpleCard</a> component.
 *
 * @typedef CoreCard
 * @property {string} [description] Additional description text to display under the card title when using the "Icon Body"
 * <code>cardTemplateType</code>.
 * @property {string} [icon]  The name of the Font Awesome icon to display.
 * @property {string} [imageUrl]  The URL to the image icon to display.
 * @property {string|number} [key]  A unique identifier for the card. This is mandatory when defining cards for the {@link CoreInctSimpleCardList}.
 * @property {CoreCardLinkData} [linkData] A {@link CoreCardLinkData} object used to generate the card's link. Required
 *  for "No Icon", "Icon Horizontal", and "Icon Vertical" <code>cardTemplateType</code> types.
 * @property {string} [sfIcon]  The name of the Salesforce [icon](https://www.lightningdesignsystem.com/components/icons/#site-main-content)
 *  to display.
 * @property {string} [svgIconUrl] The URL to the SVG icon to display.
 * @property {string} title The text to use for the card title. The title overrides the {@link CoreCardLinkData} label
 *  as the slot content for coreIntcLink when the "Icon Body" <code>cardTemplateType</code> is used.
 */


/**
 * Represents a <a href="CoreIntcLink.html">CoreIntcLink</a> to be displayed in a <a href="CoreIntcSimpleCard.html">CoreIntcSimpleCard</a>.
 * Set on the <a href="global.html#CoreCard">CoreCard</a> object.
 *
 * @typedef CoreCardLinkData
 * @property {string} label  The label to be passed to the coreIntcLink component.
 * @property {string} [communityPage]  The Named Page Type (Experience Builder Sites) Salesforce
 *  [PageReference](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type)
 *  to be passed to the coreIntcLink component.
 * @property {string} [externalUrl]  The externalUrl to be passed to the coreIntcLink component.
 * @property {string} [objectPage]  The The objectApiName when using an Object Type Salesforce
 *  [PageReference](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type)
 *  to be passed to the coreIntcLink component.
 * @property {string} [recordId]  The recordId to be passed to the coreIntcLink component.
 */