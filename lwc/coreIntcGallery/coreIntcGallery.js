import { api, LightningElement } from 'lwc';
import CoreResource from '@salesforce/resourceUrl/Core_INTC';

// Custom labels
import modalTitle from '@salesforce/label/c.Core_Intc_GalleryModalTitle';
import open from '@salesforce/label/c.Core_Intc_GalleryModalOpen';
import closeModal from '@salesforce/label/c.Core_Intc_CloseModal';
import displayImage from '@salesforce/label/c.Core_Intc_GalleryNowDisplayingImage';
import displayVideo from '@salesforce/label/c.Core_Intc_GalleryNowDisplayingVideo';
import indicatorImgText from '@salesforce/label/c.Core_Intc_Gallery_Indicator_Image';
import indicatorVidText from '@salesforce/label/c.Core_Intc_Gallery_Indicator_Video';


/**
 * @typedef Indicator
 * @property {string} src Url of the image
 * @property {string} type Type of the indicator, currently supported (image, video)
 */

/**
 * @typedef GalleryContents
 * @property {string} imageUrl url for image
 * @property {string} thumbnailUrl url for thumbnail
 * @property {string} altText text for alt attribute
 * @property {string} videoId id of the video
 * @property {string} accountId Id of the Brightcove account. Used if [videoType='Brightcove']
 * @property {string} file Url of the video file (in mp4 format). Used if [videoType='file']
 * @property {string} title Title of the video
 * @property {string} videoType Type of the video, supported: youtube, brightcove, file
 * @property {string} placeholder246px Place holder thumbnail to use if video is not present (small)
 * @property {string} placeholder1920px Place holder thumbnail to use if video is not present (large)
 */

/**
 * Uses the {@link CoreIntcModal} to display a {@link CoreIntcCarousel} of images & videos.
 *
 * The gallery has two standard displays:
 * 1. The first image is shown and users can click on it to open a modal to view all the images. This version is displayed when
 *   <code>thumbnailOnCover</code> is set to false.
 * 2. The first image is shown along with thumbnail versions of all other images beneath it. Users can navigate through
 *    these images, or click on them to open the modal display. This version is displayed when <code>thumbnailOnCover</code> is set to true.
 *
 * ### CSS Variables
 * | Name | Default | Description |
 * | ---- | ------- | ----------- |
 * | intc-gallery-image-align-items | center | align-items property for the gallery images. |
 * | intc-gallery-image-border-color | carbon-tint2 | Border color for the gallery image container. |
 * | intc-gallery-image-justify-content | center | justify-content property for the gallery images. |
 * | See the {@link CoreIntcCarousel} for additional variables. |
 *
 * ### Notes:
 * * Clicking on the initial image (the gallery cover) will open the gallery.
 * * All images should be similar in size.
 * * A maximum of 12 images can be displayed in the gallery.
 * * Images can be navigated to via mouse click, or pressing the tab/arrow keys.
 * * Thumbnails will always be displayed for images in the modal. To display thumbnails at the bottom of gallery cover
 *   set <code>thumbnailOnCover</code> to true.
 * * To display videos <code>thumbnailOnCover</code> must be set to true.
 *
 * <div id="core-examples" sf-attr="c-coreintcgallery_coreintcgallery c-coreintccarousel_coreintccarousel c-coreintcmodal_coreintcmodal">
 *  <demo-core-intc-gallery show1="true"></demo-core-intc-gallery>
 *  <demo-core-intc-gallery show2="true"></demo-core-intc-gallery>
 *  <demo-core-intc-gallery show3="true"></demo-core-intc-gallery>
 * </div>
 *
 * @example
 * // JavaScript component example 1 - using objects
 * images1 = [
 *   {
 *     altText: 'Sindrax image 1',
 *     imageUrl: 'Sindrax1.png',
 *     thumbnailUrl: 'Sindrax1.png',
 *   },
 *   {
 *     altText: 'Sindrax image 2',
 *     imageUrl: 'Sindrax2.png',
 *     thumbnailUrl: 'Sindrax2.png',
 *   },
 *   {
 *     altText: 'Sindrax image 3',
 *     imageUrl: 'Sindrax3.png',
 *     thumbnailUrl: 'Sindrax3.png',
 *   },
 *   {
 *     altText: 'Sindrax image 4',
 *     imageUrl: 'Sindrax4.png',
 *     thumbnailUrl: 'Sindrax4.png',
 *   },
 * ];
 *
 * @example
 * <!-- HTML component example 1 -->
 * <c-core-intc-gallery images={images1}></c-core-intc-gallery>
 *
 * @example
 * // JavaScript component example 2 - using strings
 * images2 = ['Sindrax1.png', 'Sindrax2.png', 'Sindrax3.png', 'Sindrax4.png', 'Sindrax1.png', 'Sindrax2.png', 'Sindrax3.png', 'Sindrax4.png',
 *   'Sindrax1.png', 'Sindrax2.png', 'Sindrax3.png', 'Sindrax4.png'];
 *
 * @example
 * <!-- HTML component example 2 -->
 * <c-core-intc-gallery images={images2} fixed-height></c-core-intc-gallery>
 *
 * @example
 * // JavaScript component example 3 - using strings
 * images2 = ['Sindrax1.png', 'Sindrax2.png', 'Sindrax3.png', 'Sindrax4.png', 'Sindrax1.png', 'Sindrax2.png', 'Sindrax3.png', 'Sindrax4.png',
 *   'Sindrax1.png', 'Sindrax2.png', 'Sindrax3.png', 'Sindrax4.png'];
 *
 * @example
 * <!-- HTML component example 3 -->
 * <c-core-intc-gallery images={images3} thumbnail-on-cover></c-core-intc-gallery>
 *
 * @augments LightningElement
 * @property {boolean} [fixedHeight=false] Indicates if the gallery cover dimensions should be a fixed height (18rem).
 * @property {GalleryContents[]|string[]} images An array of {@link GalleryContents} objects or image src strings. The
 *  {@link GalleryContents} format is preferred since it provides accessibility alt text for images & video thumbnails.
 * @property {boolean} [thumbnailOnCover=false] Indicates whether thumbnail should be shown at the bottom of the gallery cover.
 */
class CoreIntcGallery extends LightningElement {
  @api fixedHeight = false;

  @api thumbnailOnCover = false;

  /**
   * Custom labels
   */
  labels = {
    modalTitle,
    open,
    closeModal,
    displayImage,
    displayVideo,
    indicatorImgText,
    indicatorVidText,
  }

  /** The message to display in the aria live container.
   *
   * @type {string}
   * @private
   */
  ariaMessage = '';

  /** Maximum number of images for the gallery
   *
   * @type {number}
   * @private
   */
  MAX_IMAGES = 12;

  /** placeholder image for the gallery (ip)
   * (This is shown if no images are passed in)
   *
   * @type {string}
   * @private
   */
  placeholderImage = `${CoreResource}/images/standard-placeholder-4x3.png`;

  @api images = [];

  /** current index of the gallery (starts at 0)
   *
   * @type {number}
   * @private
   */
  currentIdx = 0;

  /**
   * If true, modal open is disabled
   *
   * @type {boolean}
   * @private
   */
  disableModalOpen = false;

  /**
   * gets current image for static view (first or placeholder by default)
   *
   * @returns {string} current image src
   * @private
   */
  get currentImage() {
    return this.formattedImages[this.currentIdx] || { url: this.placeholderImage };
  }

  /**
   * gets the copy for the counter (ie. 1 of 5)
   *
   * @returns {string} text copy
   * @private
   */
  get counterText() {
    return `${this.currentIdx + 1} of ${this.images.length}`;
  }

  /**
   * gets formatted objects with image url and key value
   * also slices to only allow for the maximum number of images
   *
   * @returns {object[]} formatted image object
   * @private
   */
  get formattedImages() {
    return this.images
      .map((img, idx) => ({
        key: `gallery-image-${idx}`,
        url: typeof img === 'string' ? img : img.imageUrl,
        alt: typeof img === 'string' || img.altText === null ? '' : img.altText,
        videoId: typeof img === 'string' ? null : img.videoId,
        videoType: typeof img === 'string' ? null : img.videoType,
        accountId: typeof img === 'string' ? null : img.accountId,
        isProcessing: img.videoType ? img.videoId == null : false,
        placeholderImg: img.placeholder1920px ? img.placeholder1920px : null,
      }))
      .slice(0, this.MAX_IMAGES);
  }

  /** thumbnails will first look for thumbnailUrl value, then imageUrl, then string value
   *
   * @returns {Indicator[]|string[]} thumbnail image urls
   * @private
   */
  get thumbnails() {
    return this.images.map((img) => ({
      src: typeof img === 'string' ? img : (img.videoThumbnailUrl || img.imageUrl || img.placeholder246px),
      type: typeof img === 'string' || img.imageUrl || !img.videoId ? 'image' : 'video',
    }));
  }

  /**
   * returns true if there are images in the image object
   *
   * @returns {boolean} if any images exist
   * @private
   */
  get hasImages() {
    return this.images.length > 0;
  }

  /**
   * Indicates if carousel indicators will display
   *
   * @returns {boolean} has indicators
   * @private
   */
  get hasIndicators() {
    return this.images.length > 1;
  }

  /**
   * Generates assistive texts to be used by thumbnail carousel
   *
   * @returns {string[]} List of assistive texts
   * @private
   */
  get indicatorAssistiveTexts() {
    const assistiveTexts = [];
    for (let i = 0; i < this.images.length; i += 1) {
      if (this.images[i].title && this.images[i].title !== '') {
        assistiveTexts.push(`${this.labels.indicatorVidText} ${this.images[i].title}`);
      } else if (this.images[i].altText && this.images[i].altText !== '') {
        assistiveTexts.push(`${this.labels.indicatorImgText} ${this.images[i].altText}`);
      } else {
        // If alt text isn't present, default alt text from carousel is used
        assistiveTexts.push(null);
      }
    }
    return assistiveTexts;
  }

  /**
   * handles click/keydown events to open the gallery modal
   * resets carousel height b/c window may have been adjusted between openings
   *
   * @param {event} evt click or keydown
   * @private
   */
  handleOpen(evt) {
    if (this.hasImages && !this.disableModalOpen) {
      const { code, type } = evt;
      if (type === 'click' || code === 'Enter') {
        this.dispatchEvent(new CustomEvent('open'));
        this.template.querySelector('c-core-intc-modal').openModal();
        this.pauseAllVideo('.cover-video');
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
          this.template.querySelector('c-core-intc-carousel.modal-carousel').resetHeight();
          this.template.querySelector('c-core-intc-carousel.modal-carousel').setRenderedCarouselState(this.currentIdx + 1);
        }, 30);
      }
    }
  }

  /**
   * handles carousel page change event
   *
   * @param {event} evt page change event from coreIntcCarousel
   * @private
   */
  handlePageChange(evt) {
    this.pauseAllVideo('');
    this.currentIdx = parseInt(evt.detail.page, 10) - 1 || 0;
    if (evt.detail.isModal) {
      this.refreshAriaLive();
      if (this.thumbnailOnCover) {
        this.template.querySelector('c-core-intc-carousel.cover-carousel').setRenderedCarouselState(this.currentIdx + 1);
      }
    }
  }

  /**
   * Tranfer focus to modal close button
   *
   * @private
   */
  focusModalClose() {
    this.template.querySelector('c-core-intc-modal').focusFirstElement();
  }

  /**
   * Called on initial component load.
   * Calls reset height if carousel is present on cover
   *
   * @private
   */
  connectedCallback() {
    if (this.thumbnailOnCover) {
      // eslint-disable-next-line @lwc/lwc/no-api-reassignments
      this.images = [...this.images];
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        this.template.querySelector('c-core-intc-carousel.cover-carousel').resetHeight();
      }, 300);
    }
  }

  /**
   * Pause all videos selected by videoSelector
   *
   * @param {string} videoSelector css Selector
   * @private
   */
  pauseAllVideo(videoSelector) {
    const videos = this.template.querySelectorAll(`c-core-intc-video${videoSelector}`);
    videos.forEach((video) => {
      video.pauseVideo();
    });
  }

  /**
   * Keydown handler. Allows tab navigation of images
   *
   * @param {object} evt Associated event object
   */
  handleKeyDown(evt) {
    if (evt.key === 'Tab') {
      const { dataset } = this.template.activeElement;
      const idx = parseInt(dataset.navigate, 10);
      if (evt.shiftKey) {
        if (idx > 0) {
          this.currentIdx = idx - 1;
        }
      } else if (!this.template.activeElement.videoType && !dataset.video && idx < Math.min(this.MAX_IMAGES, this.images.length) - 1) {
        this.currentIdx = idx + 1;
      }
      this.setCarouselState(this.currentIdx + 1, dataset.modal);
    }
  }

  /**
   * Set rendered carousel state based on the provided index
   *
   * @param {number} idx Index of the carousel to render to (1-based index)
   * @param {boolean} isModal If true, set modal carousel state as well
   */
  setCarouselState(idx, isModal) {
    this.pauseAllVideo('');
    if (isModal) {
      this.template.querySelector('c-core-intc-carousel.modal-carousel').setRenderedCarouselState(idx);
      this.refreshAriaLive();
    }
    this.template.querySelector('c-core-intc-carousel.cover-carousel').setRenderedCarouselState(idx);
  }

  /**
   * On keyboard focus, ensure gallery is rendered in a corrrect state
   *
   * @private
   */
  handleGalleryItemFocus() {
    const { dataset } = this.template.activeElement;
    this.currentIdx = parseInt(dataset.navigate, 10);
    this.setCarouselState(this.currentIdx + 1, dataset.modal);
  }


  /**
   * Accssibility - Refresh aria-live message based on the current item active
   *
   * @private
   */
  refreshAriaLive() {
    let updatedMsg;
    if (this.images[this.currentIdx].title && this.images[this.currentIdx].title !== '') {
      updatedMsg = `${this.labels.displayVideo} ${this.images[this.currentIdx].title}`;
    } else if (this.images[this.currentIdx].altText && this.images[this.currentIdx].altText !== '') {
      updatedMsg = `${this.labels.displayImage} ${this.images[this.currentIdx].altText}`;
    }
    this.ariaMessage = updatedMsg;
  }

  /**
   * Handler for gallery modal onclose event
   *
   * @private
   */
  handleModalClose() {
    this.pauseAllVideo('');
    this.tempDisableModalOpen();
    this.focusCurrentlyActive();
  }

  /**
   * Temporary disables modal open.
   * Used to resolve issue where handleOpen was immediately called after closing modal with enter
   *
   * @private
   */
  tempDisableModalOpen() {
    this.disableModalOpen = true;
    const self = this;
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      self.disableModalOpen = false;
    }, 50);
  }

  /**
   * Accessibility - If the current element is video, transfer focus to it.
   *
   * @private
   */
  focusVideo() {
    const items = this.template.querySelectorAll('c-core-intc-modal .gallery-image-container');
    if (items[this.currentIdx].dataset.video) {
      const selector = `c-core-intc-modal .gallery-image-container:nth-of-type(${this.currentIdx + 1}) c-core-intc-video`;
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        this.template.querySelector(selector).focus();
      }, 20);
    }
  }

  /**
   * Focus on currently active gallery item.
   * Used on modal close
   *
   * @private
   */
  focusCurrentlyActive() {
    const items = this.template.querySelectorAll('c-core-intc-carousel.cover-carousel .gallery-image-container');
    let selector;
    if (items[this.currentIdx].dataset.processing) {
      selector = `c-core-intc-carousel.cover-carousel .gallery-image-container:nth-of-type(${this.currentIdx + 1}) img`;
    } else if (items[this.currentIdx].dataset.video) {
      selector = `c-core-intc-carousel.cover-carousel .gallery-image-container:nth-of-type(${this.currentIdx + 1}) c-core-intc-video`;
    } else {
      selector = `c-core-intc-carousel.cover-carousel .gallery-image-container:nth-of-type(${this.currentIdx + 1}) .expand-icon-wrapper`;
    }
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      this.setCarouselState(this.currentIdx + 1);
      this.template.querySelector(selector).focus();
    }, 10);
  }
}
export default CoreIntcGallery;