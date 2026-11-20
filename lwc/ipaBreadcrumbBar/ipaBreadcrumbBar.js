import { LightningElement } from 'lwc';

export default class IpaBreadcrumbBar extends LightningElement {
  
  // ******* Track variables ********
  /**
  * Full URL for this domain. Used for window messaging.
  * @type {string}
  * @private
  */
 fullLocation = window.location.protocol + '//' + window.location.hostname + (window.location.port ? ':' + window.location.port : '');


  /**
   * The HTML element representing the currently displayed popup.
   * @type {Object}
   * @private
   */
  openPopup;


  /**
   * An array of selected navigation breadcrumbs.
   * @type {Object[]}
   * @private
   */
  selectedItems = [];




  // ******* Functions ********
  /**
   * Sets the array of selected breadcrumbs. This will display the navigation.
   * @param {Object} navigation  The JSON object containing the navigation hierarchy.
   * @private
   */
  buildNavigation(navigation) {
    this.selectedItems = this.getSelectedItems(navigation.breadcrumb);
  }



  /**
   * Called when the element is inserted into the DOM. Used to add a window message listener.
   * @private
   */
  connectedCallback() {
    this.sanitizeChildren();
    window.addEventListener("message", this.handleMessage, false);
  }



  /**
   * Called when the element is removed from the DOM. Used to remove the window message
   * and click listeners.
   * @private
   */
  disconnectedCallback() {
    window.removeEventListener("message", this.handleMessage);
    window.removeEventListener("click", this.handleWindowClick);
  }



  /**
   * Goes through the child links of a selected navigation link/breadcrumb and returns
   * the selected child.
   * @param {Object[]} children  An array of child navigation links for a breadcrumb.
   * @returns {Object} The selected child navigation link/breadcrumb.
   * @private
   */
  getNextSelectedItem(children) {
    // Default to null
    let selectedItem;

    // Check for children
    if (children) {
      const length = children.length;

      // Loop through all children
      for (let count=0; count < length; count++) {
        this.testForId(children[count]);

        // Check if selected
        if (children[count].selected) {
          selectedItem = children[count];
        }
        // Determine if child is text only
        if (!children[count].url && !children[count].useCallback) {
          children[count].textOnly = true;
        }
      };
    }
    return selectedItem;
  }



  /**
   * Recursively goes through the navigation JSON and builds an array of selected breadcrumbs/links.
   * @param {Object} breadcrumb  The top level breadcrumb object in the navigation JSON.
   * @returns {Object[]} The selected child navigation links/breadcrumbs.
   * @private
   */
  getSelectedItems(breadcrumb) {
    const items = [];
    let selectedItem = breadcrumb;

    // Continue looping while there is a selected breadcrumb
    while (selectedItem) {
      this.testForId(selectedItem);
      items.push(selectedItem);

      // Set properties used in the template to render the breadcrumb/link
      selectedItem.className = `breadcrumbPopup breadcrumbPopup-${items.length - 1}`;
      if (!selectedItem.children || selectedItem.children.length === 0) {
        selectedItem.noChildren = true;
      }
      if (!selectedItem.url && !selectedItem.useCallback) {
        selectedItem.textOnly = true;
      }

      // Check if any of the breadcrumb's children are selected
      selectedItem = this.getNextSelectedItem(selectedItem.children);
    }
    return items;
  }



  /**
   * Called when a user clicks on a navigation link. Used to determine if a callback
   * must be invoked and propagation cancelled.
   * @param {Object} evt  The Javascript click event object.
   * @private
   */
  handleLinkClick(evt) {
    // Get the data object for the link that was clicked on
    const parentIndex = evt.currentTarget.dataset.index;
    const id = evt.currentTarget.dataset.id;
    const clickedItem = this.selectedItems[parentIndex].children.find((item) => {
      return item.id == id;
    });

    if (clickedItem) {
      if (clickedItem.useCallback) {
        window.postMessage({type: 'intel.clickNavigate', data: clickedItem.data}, this.fullLocation);
      }
      if (clickedItem.cancelEvent) {
        evt.stopPropagation();
      }
    }

    // Close popup after clicking on a link
    this.setPopupState(this.openPopup, 'none');
  }
 


  /**
   * Called when a window message is received. Messaging is used to communicate with scripts in the
   * community's HEAD element, which in turn communicate with third party scripts.
   * @param {Object} evt  The Javascript message event object.
   * @private
   */
  handleMessage = (evt) => {
    if (evt.origin === this.fullLocation && evt.data && evt.data.type === 'intel.buildNavigation') {
      this.buildNavigation(evt.data.data);
    }
  }



  /**
   * Called when the user clicks on the page. Used to determine if a popup menu should be hidden.
   * @param {Object} evt  The Javascript click event object.
   * @private
   */
  handleWindowClick = (evt) => {
    if (this.openPopup && !this.openPopup.parentElement.parentElement.contains(evt.target)) {
      this.setPopupState(this.openPopup, 'none');
    }
  }



 /**
 * Sets the display state of a popup menu. Adds or removes event listeners
 * based on the state.
 * @param {Object} popup  The HTML element thaat is the popup.
 * @param {string} display  The display style to be applied to the popup.
 * @private
 */
 setPopupState(popup, display) {
   popup.style.display = display;
   if (display === 'none') {
     this.openPopup = null;
     window.removeEventListener("click", this.handleWindowClick);
   } else {
     window.addEventListener("click", this.handleWindowClick, false);
     this.openPopup = popup;
   }
  }



  /**
   * Tests that a breadcrumb includes an ID value.
   * @param {Object} breadcrumb  The breadcrumb to test for an ID.
   * @private
   */
  testForId(breadcrumb) {
    if (breadcrumb.id === undefined || breadcrumb.id === null) {
      throw `Error in Breadcrumbs - "${breadcrumb.text}" does not have an ID`;
    } 
  }



  /**
   * Toggles the display of a popup menu.
   * @param {Object} evt  The Javascript click event object.
   * @private
   */
  toggleBreadcrumb(evt) {
    // Get the popup HTML element
    const index = evt.currentTarget.dataset.index;
    const popupItem = this.selectedItems[index];
    const popup = this.template.querySelector(`.breadcrumbPopup-${index}`);

    // Hide the currently open popup if it is not this one
    if (this.openPopup && popup !== this.openPopup) {
      this.setPopupState(this.openPopup, 'none');
    }

    // Hide or show the popup depending on its current state
    if (popupItem.children && popupItem.children.length) {
      if (popup) {
        if (popup.style.display === 'block') {
          this.setPopupState(popup, 'none');
        } else {
          this.setPopupState(popup, 'block');
        }
      }
    }

    evt.stopPropagation();
  }

  SanitizeChildren() {
    this.sanitizedChildren = this.it.value.children.map(child => {
        return {
            ...child,
            sanitizedUrl: this.sanitizedUrl(child.url),
            computedRel: this.computedRel(child.target)
        };
    });
}

sanitizedUrl(url) {
    // Implement URL sanitization logic here
    if (url && (url.startsWith('http://') || url.startsWith('https://'))) {
        return url;
    }
    return 'about:blank';
}

computedRel(target) {
    // If target is _blank, add rel="noopener noreferrer" for security
    return target === '_blank' ? 'noopener noreferrer' : undefined;
}
}