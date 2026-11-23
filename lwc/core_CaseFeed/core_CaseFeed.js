import { LightningElement, api, track } from 'lwc';
import getFeedElements from '@salesforce/apex/core_S2S_CaseExternalFeedController.getFeedElements';
import getExternalID from '@salesforce/apex/core_S2S_CaseExternalFeedController.getExternalID';

/**
   * LWC for the external case feed
   * The feed filters out most automated messages and shows feed emails
   * Redundant if-statements are common before addressing deeper layers of a feed element
   * since not all feed elements contain the same fields and attributes and thus are undefined
   * which will result in the code stopping when it tries to read a field of an undefined value
   * !!Email recipients that are cc'ed on the email appear in the 
   * feed element but is not yet implemented in the HTML!!
   */

export default class caseFeed extends LightningElement {
    //The Sales Cloud record Id
    @api recordId;
    //Array containing the indexes of the elements that contain an email
    @track elementHasEmailIndexs = [];

    //Used to ensure the emails display in the correct order
    @track nextEmail = [false, false, false, false, false, false];

    //the updated feed elements array that is iterated over in the HTML
    @track feed = [];

    //Copy of the elements
    elementsC;
    space = ' ';
    //Images used for the profile pictures
    completedImage = 'https://isvc--isvcai.lightning.force.com/img/entitlement/completed.png';
    violatedImage = 'https://intel--crmpoc4.lightning.force.com/img/entitlement/violation.png';
    defaultProfileImage = 'https://isvc--isvcai.my.salesforce.com/img/userprofile/default_profile_200_v2.png?fromEmail=1';
    blueOwlImage = 'https://intel--crmpoc4.my.salesforce.com/_slds/images/themes/lightning_blue/lightning_blue_profile_avatar_96.png';

    /** 
     * Since feedElement is read-only and cannot be altered, a copy of each layer is made
     * Each copy can only be changed up to one layer deep
     * Example: actorC.photo can be changed but actorC.photo.fullEmailPhotoUrl cannot 
     *          be changed because it is 2 layers deep
     * The determining factor for whether an element will show up in the feed or be skipped is its actor.photo
     * If an element has an actor.photo.fullEmailPhotoUrl that is either
     *    https://isvc--isvcai.lightning.force.com/img/entitlement/completed.png
     * or
     *    https://intel--crmpoc4.lightning.force.com/img/entitlement/violation.png
     * will be skipped but can easily be changed to re-allow them to show up
     * Any element without a photo URL will be given one in case the code is changed to allow them to show up
     */


    connectedCallback() {
        this.initFeed();
    }
    handleRefresh(){
        
        window.location.reload();
        //eval("$A.get('e.force:refreshView').fire();");
    }

    async initFeed() {
        try {
            //Returns the realted Service Cloud record Id
            this.externalId = await getExternalID({ recordId: this.recordId });

            //Returns an array of the 25 most recent feed elements
            this.feedElement = await getFeedElements({ recordId: this.externalId });

        }
        catch (error) {
        }


        //Creates a copy of each layer
        this.elementsC = [...this.feedElement.elements];
        var element1;
        var actorC;
        var photoC;

        for (var i = 0; i < this.feedElement.elements.length; i++) {
            //Loops through the feedElements and updates element and actor copies
            element1 = { ...this.feedElement.elements[i] };
            actorC = { ...this.feedElement.elements[i].actor };

            //Checks if the element has an actor attribute (not all elements have an actor)
            if (this.feedElement.elements[i].actor) {
                //if there is an actor, update the copy of its photo
                photoC = { ...this.feedElement.elements[i].actor.photo };
            }
            //If no actor, give it one and a photo
            else {
                actorC = {
                    name: 'No Actor',
                    Photo: '',
                }
                photoC.fullEmailPhotoUrl = this.completedImage;
            }

            //Checks if the feedElement has a header (not all elements have one)
            if (this.feedElement.elements[i].header) {
                //Checks if the header has a messageSegments (not all headers have one)
                if (this.feedElement.elements[i].header.messageSegments) {
                    //Sets jString equal to the string value of header.messageSegments
                    //This will be used to check for common automated messages to set their actor photo
                    var jString = JSON.stringify(this.feedElement.elements[i].header.messageSegments);
                    if (jString.includes('violation')) {
                        photoC.fullEmailPhotoUrl = this.violationImage;
                    }
                    //common automated message
                    else if (jString.includes('SLA') || jString.includes('Respons') || jString.includes('updated this record')) {
                        photoC.fullEmailPhotoUrl = this.completedImage;
                    }
                }
            }
            //Checks if the element has an actor (not all elements have one)
            if (this.feedElement.elements[i].actor) {
                if (this.feedElement.elements[i].actor.entityLabel)
                {
                    if (this.feedElement.elements[i].actor.entityLabel.label === 'Case Milestone' || this.feedElement.elements[i].actor.name === 'Automated Process') {
                        photoC.fullEmailPhotoUrl = this.completedImage;
                    }
                }
                
                //Checks if the actor has a photo (not all actors have one)
                if (this.feedElement.elements[i].actor.photo) {
                    //Changes the default avatar photo the the Service Cloud default blue owl photo
                    if (this.feedElement.elements[i].actor.photo.fullEmailPhotoUrl === this.defaultProfileImage
                        && photoC.fullEmailPhotoUrl !== this.completedImage && photoC.fullEmailPhotoUrl !== this.violationImage) {
                        photoC.fullEmailPhotoUrl = this.blueOwlImage;
                    }
                }

                //Checks if there is no photo and the element is not automated and photoC has not been set
                //If so, sets the photo to the default Service Cloud email avatar
                if (!this.feedElement.elements[i].actor.photo && !photoC.fullEmailPhotoUrl) {
                    photoC.fullEmailPhotoUrl = this.defaultProfileImage;
                }
            }

            //Sets the new copies one layer at a time because they are read only
            actorC.photo = photoC;
            element1.actor = actorC;
            this.elementsC[i] = element1;
        }

        //After setting all of the copy elements, the final array of elements is stored in this.feed
        //this.feed is the array that is iterated over in the HTML file
        this.feed = this.elementsC;

        for (var i = 0; i < this.feed.length; i++) {
            this.feed[i].showElement = this.showElement(i),
            this.feed[i].hasEmail = this.hasEmail(i),
            this.feed[i].profileLink = this.getLink(i),
            this.feed[i].likeCount = this.likeCount(i),
            this.feed[i].bodyMessage = this.getBodyText(i)
        }
        console.log(this.feed);
    }


    /** 
     * Returns true or false based on whether the element will be skipped or not
     * Elements that seem to be automated will be skipped based on their actor photo
     */
    showElement(i) {
        //To re-allow automated messages to show up, alter this if statement 
        if (this.elementsC[i].actor.photo.fullEmailPhotoUrl === this.completedImage
            || this.elementsC[i].actor.photo.fullEmailPhotoUrl === this.violationImage) {
            return false;
        }
        else {
            return true;
        }
    }

    /** 
     * Returns true or false based on whether the element contains an email
     * Used in the HTML to write out the sender and recipients of the email
     * along with the button to expand email
     */
    hasEmail(i) {
        if (this.feedElement.elements[i].capabilities) {
            if (this.feedElement.elements[i].capabilities.emailMessage) {
                return true;
            }
        }
        return false;
    }

    /** 
     * Returns the body of the feed element
     * If the element has an email, add its index to an array
     * If an element has no body text, use the header as the body text
     */
    getBodyText(i) {

        //Checks if the element has capabilities, a body, and a header
        if (this.feedElement.elements[i].capabilities
            && this.feedElement.elements[i].body
            && this.feedElement.elements[i].header) {
            //Checks if the element has an email
            if (this.feedElement.elements[i].capabilities.emailMessage) {
                this.elementHasEmailIndexs.push(i);
                return '';
            }

            //Cecks if the element has no body
            else if (!this.feedElement.elements[i].body.text) {
                return this.feedElement.elements[i].header.text;
            }

            /** 
             * If the element has a body and no email, check for apostrophes
             * Apostrophes apear as their ASCII value (&#39;) for an unknown reason
             * So if the body contains (&#39;) it gets converted into an apostrophe
             * Again, uses copies to change the value of body.text one layer at a time
             */
            else {
                if (this.feedElement.elements[i].body.text.includes('&#39;')) {
                    var elementsC2 = [...this.feedElement.elements];
                    var element2 = { ...this.feedElement.elements[i] };
                    var bodyC = { ...this.feedElement.elements[i].body };
                    var textC = { ...this.feedElement.elements[i].body.text };
                    textC = this.feedElement.elements[i].body.text.replaceAll('&#39;', '');
                    bodyC.text = textC;
                    element2.body = bodyC;
                    elementsC2[i] = element2;
                    return elementsC2[i].body.text
                }
                return this.feedElement.elements[i].body.text;
            }
        }
    }


    /** 
     * Returns the Service Cloud User URL page
     * Used when the user clicks on the profile picture or name in the feed
     */
    getLink(i) {
        var profileLink = '';
        if (this.feedElement.elements[i].actor) {
            if (this.feedElement.elements[i].actor.id) {
                profileLink = 'https://isvc--isvcai.lightning.force.com/lightning/r/User/' + this.feedElement.elements[i].actor.id + '/view';
            }
        }
        return profileLink;
    }

    /** 
     * Returns the number of likes on a feed element
     * Resets the count if it reaches above 24 in the case of the button being pressed multiple times
     */
    likeCount(i) {
        var c;
        if (this.feedElement.elements[i].capabilities) {
            //If no upDownVote, set likes equal to zero
            if (!this.feedElement.elements[i].capabilities.upDownVote) {
                c = 0;
            }
            else {
                c = this.feedElement.elements[i].capabilities.upDownVote.upVoteCount;
            }
        }
        return c;
    }

    /** 
     * Used to expand the emails in the feed
     * !!Currently expands all emails in the feed reguardless of which 
     * expand-button is pressed and there is no shrink button!!
     */
     expandEmail() {
        //Hardcoded for 6 emails
        for (var i = 0; i < 6; i++) {
            //Uses the email indexes set in getBodyText()
            if (this.feedElement.elements[this.elementHasEmailIndexs[i]]) {
                //This element should have capabilities.emailMessage, but these if statements are just a precaution 
                if (this.feedElement.elements[this.elementHasEmailIndexs[i]].capabilities) {
                    if (this.feedElement.elements[this.elementHasEmailIndexs[i]].capabilities.emailMessage) {
                        //Creates the body of the email and removes the HTML tags
                        if (this.nextEmail[i]) {
                            var msg = (this.feedElement.elements[this.elementHasEmailIndexs[i]].capabilities.emailMessage.body);
                            var textArea = document.createElement('div');
                            textArea.innerHTML = msg;
                            textArea.innerHTML = textArea.innerText;

                            //Fills the email into the respective container in the HTML
                            var container;
                            container = this.template.querySelector('.container' + i);
                            container.innerHTML = textArea.innerHTML;
                        }
                    }
                }
            }
        }
        
    }

    /** 
     * show0() - show5() are used in the HTML to set the doms manually
     * Their order is critical so that the emails show up in the correct order as they would on the feed
     * show1() only returns true if show0() has been called and show2() returns true if show1() has been called
     * !!Curently only shows the 6 most recent emails in the feed!!
     */
    get show0() {
        this.nextEmail[0] = true;
        return true;
    }

    get show1() {
        if (this.nextEmail[0]) {
            this.nextEmail[1] = true;
            return true;
        }
        else {
            return false;
        }
    }
    get show2() {
        if (this.nextEmail[1]) {
            this.nextEmail[2] = true;
            return true;
        }
        else {
            return false;
        }
    }
    get show3() {
        if (this.nextEmail[2]) {
            this.nextEmail[3] = true;
            return true;
        }
        else {
            return false;
        }
    }
    get show4() {
        if (this.nextEmail[3]) {
            this.nextEmail[4] = true;
            return true;
        }
        else {
            return false;
        }
    }
    get show5() {
        if (this.nextEmail[4]) {
            this.nextEmail[5] = true;
            return true;
        }
        else {
            return false;
        }
    }
}