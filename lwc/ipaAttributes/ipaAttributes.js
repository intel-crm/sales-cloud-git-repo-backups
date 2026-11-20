import { LightningElement, api } from 'lwc';

/**
 * @typedef AttributeValue
 * @property {string} label text label for attribute
 * @property {boolean} [isLink] true if label should be a link
 * @property {string} [objectPage] page for object api for link
 * @property {string} [recordId] record id for object for link
 * @property {object} [searchParams] search params for L2 links
 * @property {string} [externalUrl] url for an external url link
 * @property {string} [class] optional class on a specific value or for custom styling/spacing
 * @property {string} key private key for template loop
 */

/** Attributes Component
 * Displays list of attributes
 * Used on product cards and partner properties lists
 * (ie. See ipaOfferingDetail component)
 *
 * @property {string} attributeClass optional additional class for each iterated attribute
 * @property {string} [separator] optional separator (makes attributes inline) ie. '|', ':', '-'
 * @property {boolean} [showLinksAsPreview] optional will disable links (preview)
 * @property {string[]|AttributeValue[]} values the values to be displayed
 * @property {boolean} [displayInline=false] displays all attributes inline instead of as a block
 * @augments LightningElement
 */
class IpaAttributes extends LightningElement {
  @api attributeClass;

  @api separator;

  @api showLinksAsPreview;

  @api values = [];

  @api displayInline = false;

  /** adds template properties to attribute value list
   *
   * @returns {AttributeValue[]} formatted attributes for html (includes 'class' and 'key')
   * @private
   */
  get formattedAttributes() {
    return this.values.map((attr, idx) => {
      const att = typeof attr === 'string' ? { label: attr } : attr;
      return {
        ...att,
        class: ['attribute-value', this.attributeClass, att.class].join(' '),
        key: `${this.title}:attribute-${idx}`,
        preview: !!this.showLinksAsPreview,
      };
    });
  }
}
export default IpaAttributes;