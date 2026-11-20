import { LightningElement, api } from 'lwc';

/**
 * Displays upload card
 *
 * @typedef FileCard
 * @property {string} brightcoveThumbnail resource brightcove thumbnail url
 * @property {string} videoPlaceholderThumbnail resource placeholder thumbnail url
 * @property {string} altText resource thumbnail alt text
 * @property {string} altTextPlaceholder placeholder thumbnail alt text
 * @property {string} fileName resource name
 * @property {string} resourceNumber resource index
 */
class IpaFileCard extends LightningElement {
  /**
   * Brightcove poster image
   *
   * @type {string}
   * @public
   */
  @api brightcoveThumbnail;

  /**
   * Placeholder image if brightcove isnt initialized
   *
   * @type {string}
   * @public
   */
  @api videoPlaceholderThumbnail;

  /**
   * Image alt text
   *
   * @type {string}
   * @public
   */
  @api altText;

  /**
   * Placeholder image alt text
   *
   * @type {string}
   * @public
   */
   @api altTextPlaceholder;

  /**
   * Name of file
   *
   * @type {string}
   * @public
   */
  @api fileName;

  /**
   * Item index
   *
   * @type {number}
   * @public
   */
  @api resourceNumber;

  /**
   * Item index
   *
   * @type {number}
   * @public
   */
   @api uploadId;
}
export default IpaFileCard;