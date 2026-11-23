import { LightningElement, api, track, wire } from 'lwc';
import getFeedElements from '@salesforce/apex/core_S2S_CaseExternalFeedController.getFeedElements';
import getExternalID from '@salesforce/apex/core_S2S_CaseExternalFeedController.getExternalID';
import postToFeed from '@salesforce/apex/core_S2S_CaseExternalFeedController.postToChatter';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLabel from '@salesforce/apex/core_S2S_CaseExternalFeedController.getLabel';
import { refreshApex } from '@salesforce/apex';
import getContentVersion from '@salesforce/apex/core_S2S_FileDownloadCaseController.getContentVersion';
import searchUsers from '@salesforce/apex/core_S2S_CaseExternalFeedController.searchUsers';
import { getRecord } from 'lightning/uiRecordApi';

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

export default class caseFeed extends LightningElement {
	@api recordId; // The Sales Cloud record Id

	// State variables
	@track feed = [];
	@track feedElement = [];
	selectVal = 'InternalUsers';
	post;
	comment;
	elementsC;
	commentId;
	index;
	space = ' ';
	isSpinner = true;
	errorCount = 0;
	feedContainEmail = false;
	labels = {};
	isMentioned = false;
	message = '';
	@track mentionPosition = {
		top: '160px',
		left: '62px'
	};
	@track mentionedUsers = [];
	@track searchTerm = '';
	@track mentionStartIndex = -1;
	isSearchResult = false;
	@track taggedUsers = [];
	@track orginalCaseRecord;
	@track caseStatus;

	isMentionedComment = false;
	colorIcon = {}
	isMentionedComment = false;
	mentionPositionComment = {
		top: '252px',
		left: '120px'
	}

	prevMentionedComment;
	@track taggedUsersInComment = [];

	/****************************************************************************************** 
	 * Handles user input for posting comments.
	 * @param {Event} event - The event containing the target value.
	 *****************************************************************************************/
	handlePostComment(event) {
		this.post = event.target.value;
		this.post = this.post;
		if (this.post.length === 0) {
			this.taggedUsers = [];
			this.isMentioned = false;
		}
	}

	@wire(getRecord, { recordId: "$recordId", fields: ['Case__x.Status__c'] })
	getCaseRecord(result) {
		this.orginalCaseRecord = result;
		if (result.error) {
			let message = "Unknown error";
			if (Array.isArray(result.error.body)) {
				message = result.error.body.map((e) => e.message).join(", ");
			} else if (typeof result.error.body.message === "string") {
				message = result.error.body.message;
			}
			this.dispatchEvent(
				new ShowToastEvent({
					title: "Error loading contact",
					message,
					variant: "error",
				}),
			);
		} else if (result.data) {
			this.caseStatus = result.data.fields.Status__c.value;
		}
	}

	/****************************************************************************************** 
	 * Return the labels and set the map.
	 * @param { } .
	 *****************************************************************************************/
	@wire(getLabel)
	getLabels({
		error,
		data
	}) {
		if (data) {
			let labels = {};
			data.forEach(lab => {
				labels[lab.Name] = lab.Value__c;
			});
			this.labels = labels;
			this.colorIcon = JSON.parse(this.labels.colorIcon);
		} else if (error) {
			console.error('Error fetching labels:', error);
		}
	}

	/****************************************************************************************** 
	 * Handles user input for posting comments.
	 * @param {Event} event - The event containing the target value.
	 *****************************************************************************************/
	handleSharePost(event) {
		postToFeed({
			recordId: this.externalId,
			postText: this.formatMessage(this.post),
			isComment: false
		}).
			then(result => {
				if (result === 201) {
					this.handleToastEvent('Success');
					this.handleRefresh();
					this.taggedUsers = []
				} else if (result === 0) {
					const event = new ShowToastEvent({
						message: 'No contact found in service cloud.',
						variant: 'error',
						mode: 'dismissable'
					});
					this.dispatchEvent(event);
				} else {
					const event = new ShowToastEvent({
						message: 'Error while posting comment',
						variant: 'error',
						mode: 'dismissable'
					});
					this.dispatchEvent(event);
				}

			})
	}

	/******************************************************************************************
	 * Refreshes the feed and resets input fields after posting.
	 *****************************************************************************************/
	handleRefresh() {
		this.isSpinner = true;
		this.initFeed();
		this.comment = '';
		this.taggedUsers = [];
		refreshApex(this.feed);
		const textareas = this.template.querySelectorAll('textarea');
		textareas.forEach(textarea => {
			textarea.value = '';
		});
	}

	/****************************************************************************************** 
	 * Toggles visibility of detailed feed element view.
	 * @param {Event} event - The event containing the target dataset.
	 *****************************************************************************************/
	handleIsVisble(event) {
		this.index = event.target.dataset.val;
		if (this.feed[this.index].isVisible) {
			this.feed[this.index].isVisible = false;
			this.feed[this.index].commentClass = 'slds-button_reset slds-post__footer-action';
		} else {
			this.feed[this.index].isVisible = true;
			this.feed[this.index].commentClass = 'slds-button_reset slds-post__footer-action slds-is-active';
		}
	}

	/****************************************************************************************** 
	 * Handles user input for posting comments.
	 * @param {Event} event - The event containing the target value.
	 *****************************************************************************************/
	handeleComment(event) {
		this.comment = event.target.value;
		if (this.comment.length === 0) {
			this.taggedUsers = [];
		}
	}

	/****************************************************************************************** 
	 * Handles user input for posting comments.
	 * @param {Event} event - The event containing the target value.
	 *****************************************************************************************/
	handleCommentOfComments(event) {
		this.commentId = event.target.dataset.id;
		postToFeed({
			recordId: event.target.dataset.id,
			postText: this.formatMessageForComment(this.comment),
			isComment: true
		})
			.then(result => {
				if (result === 201) {
					this.handleToastEvent('Success');
					this.handleRefresh();
					this.taggedUsers = [];
				} else {
					const event = new ShowToastEvent({
						message: 'Error while posting comment',
						variant: 'error',
						mode: 'dismissable'
					});
					this.dispatchEvent(event);
				}
			});
	}

	/******************************************************************************************
	 * Initializes the component upon connection, fetching external Id and initializing feed.
	 *****************************************************************************************/
	connectedCallback() {
		getExternalID({
			recordId: this.recordId
		}).then(result => {
			this.externalId = result;
			this.initFeed();
		});
	}

	/******************************************************************************************
	 * Initializes the feed by fetching elements and processing them for display.
	 *****************************************************************************************/
	initFeed() {
		getFeedElements({
			recordId: this.externalId
		}).
			then((data, error) => {
				if (data) {
					this.feedElement = data;
					this.elementsC = [...this.feedElement.elements];
					var element1;
					var actorC;
					var photoC;
					for (var i = 0; i < this.feedElement.elements.length; i++) {
						element1 = {
							...this.feedElement.elements[i]
						};
						actorC = {
							...this.feedElement.elements[i].actor
						};
						if (this.feedElement.elements[i].actor) {
							photoC = {
								...this.feedElement.elements[i].actor.photo
							};
						} else {
							actorC = {
								name: 'No Actor',
								Photo: '',
							}
							photoC.fullEmailPhotoUrl = this.labels.completedImage;
						}

						if (this.feedElement.elements[i].header) {
							if (this.feedElement.elements[i].header.messageSegments) {
								var jString = JSON.stringify(this.feedElement.elements[i].header.messageSegments);
								if (jString.includes('violation')) {
									photoC.fullEmailPhotoUrl = this.labels.violationImage;
								} else if (jString.includes('SLA') || jString.includes('Respons') || jString.includes('updated this record')) {
									photoC.fullEmailPhotoUrl = this.labels.completedImage;
								}
							}
						}
						if (this.feedElement.elements[i].actor) {
							if (this.feedElement.elements[i].actor.entityLabel) {
								if (this.feedElement.elements[i].actor.entityLabel.label === 'Case Milestone' || this.feedElement.elements[i].actor.name === 'Automated Process') {
									photoC.fullEmailPhotoUrl = this.labels.completedImage;
								}
							}

							if (this.feedElement.elements[i].actor.photo) {
								if (this.feedElement.elements[i].actor.photo.fullEmailPhotoUrl === this.labels.defaultProfileImage &&
									photoC.fullEmailPhotoUrl !== this.labels.completedImage && photoC.fullEmailPhotoUrl !== this.labels.violationImage) {
									photoC.fullEmailPhotoUrl = this.labels.blueOwlImage;
								}
							}

							if (!this.feedElement.elements[i].actor.photo && !photoC.fullEmailPhotoUrl) {
								photoC.fullEmailPhotoUrl = this.labels.defaultProfileImage;
							}
						}

						actorC.photo = photoC;
						element1.actor = actorC;
						this.elementsC[i] = element1;
					}

					this.feed = this.elementsC;
					for (var i = 0; i < this.feed.length; i++) {
						if (this.feed[i].actor.name !== 'No Actor') {
							this.feed[i].showElement = this.showElement(i);
							this.feed[i].hasEmail = this.hasEmail(i);
							this.feed[i].bodyMessage = this.getBodyText(i);
							this.feed[i].commentComments = this.getCommentOfComments(i);
							this.feed[i].setCommentId = this.setCommentId(i);
							this.feed[i].isVisible = false;
							this.feed[i].isSomoneMentioned = false;
							this.feed[i].indexValue = i;
							this.feed[i].commentClass = 'slds-button_reset slds-post__footer-action';
							this.feed[i].emailBody = this.setEmailContent(i);
							this.feed[i].setEmailClassName = 'emailBody' + this.feed[i].setCommentId;
						}
					}

					if (this.index != null && this.index != undefined) {
						if (this.feed[this.index].isVisible) {
							this.feed[this.index].isVisible = false;
							this.feed[this.index].commentClass = 'slds-button_reset slds-post__footer-action';
						} else {
							this.feed[this.index].isVisible = true;
							this.feed[this.index].commentClass = 'slds-button_reset slds-post__footer-action slds-is-active';
						}
					}

					this.handleSpinner();
				} else if (error) {
					this.errorCount += 1;
					if (this.errorCount <= 1) {
						this.handleRefresh();
					} else {
						this.handleToastEvent('Error');
					}

				}
			});

	}

	/****************************************************************************************** 
	 * Handles element visiblity.
	 * @param {Current FeedElement} i - The i containing the current feed element.
	 *****************************************************************************************/
	showElement(i) {
		if (this.elementsC[i].actor.photo.fullEmailPhotoUrl === this.labels.completedImage || this.elementsC[i].actor.photo.fullEmailPhotoUrl === this.labels.violationImage) {
			return false;
		} else if (this.feedElement.elements[i].capabilities.emailMessage) {
			return false;
		} else {
			return true;
		}
	}

	/****************************************************************************************** 
	 * Handles whether comments contain email.
	 * @param {Current FeedElement} i - The i containing the current feed element.
	 *****************************************************************************************/
	hasEmail(i) {
		if (this.feedElement.elements[i].capabilities) {
			if (this.feedElement.elements[i].capabilities.emailMessage) {
				this.feedContainEmail = true;
				return true;
			}
		}
		return false;
	}

	/****************************************************************************************** 
	 * Return the comment body message.
	 * @param {Current FeedElement} i - The i containing the current feed element.
	 *****************************************************************************************/
	getBodyText(i) {
		let commentWithUser = {
			user: 'Sales to Service Case',
			message: ''
		};
		if (this.feedElement.elements[i].capabilities && this.feedElement.elements[i].body && this.feedElement.elements[i].header && this.feedElement.elements[i].actor) {
			if (this.feedElement.elements[i].capabilities.emailMessage) {
				commentWithUser.user = this.feedElement.elements[i].actor.displayName;
				return commentWithUser;
			} else if (!this.feedElement.elements[i].body.text) {
				commentWithUser.user = this.feedElement.elements[i].actor.displayName;
				commentWithUser.message = this.feedElement.elements[i].header.text;
				return commentWithUser;
			} else {
				/** 
				 * If the element has a body and no email, check for apostrophes
				 * Apostrophes apear as their ASCII value (&#39;) for an unknown reason
				 * So if the body contains (&#39;) it gets converted into an apostrophe
				 * Again, uses copies to change the value of body.text one layer at a time
				 */
				if (this.feedElement.elements[i].body.text.includes('&#39;')) {
					var elementsC2 = [...this.feedElement.elements];
					var element2 = {
						...this.feedElement.elements[i]
					};
					var bodyC = {
						...this.feedElement.elements[i].body
					};
					var textC = {
						...this.feedElement.elements[i].body.text
					};
					textC = this.feedElement.elements[i].body.text.replaceAll('&#39;', '');
					textC = textC.replaceAll('\n', '<br>');
					bodyC.text = textC;
					element2.body = bodyC;
					elementsC2[i] = element2;
					return elementsC2[i].body.text
				}
				var value = this.convertMessageSegementInHTML(this.feedElement.elements[i].body.messageSegments);
				var getUser = this.feedElement.elements[i].body.text;
				if (getUser.includes('On behalf of')) {
					let startIndex = getUser.indexOf('of') + 3;
					let endIndex = getUser.indexOf('\n');
					let user = getUser.substring(startIndex, endIndex);
					commentWithUser.user = user;
					commentWithUser.message = value;
				} else {
					commentWithUser.user = this.feedElement.elements[i].actor.displayName;
					commentWithUser.message = value;
				}
				return commentWithUser;
			}
		}
		return commentWithUser;
	}

	/****************************************************************************************** 
	 * Return the value of comments of comments.
	 * @param {Current FeedElement} i - The i containing the current feed element.
	 *****************************************************************************************/
	getCommentOfComments(i) {
		var val = [];
		if (this.feedElement.elements[i].capabilities.comments) {
			var items = this.feedElement.elements[i].capabilities.comments.page.items;
			items.forEach(ele => {
				let value = {};
				let commentWithUser = {
					user: 'Sales to Service Case',
					message: ''
				};
				if (ele.body.messageSegments) {
					commentWithUser.message = this.convertMessageSegementInHTML(ele.body.messageSegments);
				} else {
					commentWithUser.message = ele.body.text;
				}
				if (ele.body.text.includes('On behalf of')) {
					let startIndex = ele.body.text.indexOf('of') + 3;
					let endIndex = ele.body.text.indexOf('\n');
					let user = ele.body.text.substring(startIndex, endIndex);
					commentWithUser.user = user;
					let messageIndex = ele.body.text.indexOf('\n') + 3;
					//commentWithUser.message = ele.body.text.substring(messageIndex, ele.body.text.length);
					//commentWithUser.message = commentWithUser.message;
				} else {
					commentWithUser.user = ele.user.displayName;
				}

				value.text = commentWithUser;
				value.relativeCreatedDate = ele.relativeCreatedDate;
				value.displayName = ele.user.displayName;
				value.fullEmailPhotoUrl = ele.user.photo.standardEmailPhotoUrl;
				val.push(value);
			})
		}
		return val;
	}

	/****************************************************************************************** 
	 * Set the comment id for each feedelement.
	 * @param {Current FeedElement} i - The i containing the current feed element.
	 *****************************************************************************************/
	setCommentId(i) {
		var val = [];
		if ((this.feedElement.elements[i].capabilities.comments.page.items).length > 0) {
			var items = this.feedElement.elements[i].capabilities.comments.page.items;
			items.forEach(ele => {
				if (!val.includes(ele.feedElement.id)) {
					val.push(ele.feedElement.id);
				}
			})

		} else {
			val.push(this.feedElement.elements[i].id);
		}
		return val;
	}

	/****************************************************************************************** 
	 * Set the body of email.
	 * @param {Event} event - The event containing the target value.
	 *****************************************************************************************/
	setEmailContent(i) {
		let emailMessage = {
			message: '',
			hasAttachment: true,
			attachments: []
		};

		if (this.feedElement.elements[i].capabilities.emailMessage) {
			var msg = (this.feedElement.elements[i].capabilities.emailMessage.body);
			var textArea = document.createElement('div');
			textArea.innerHTML = msg;
			textArea.innerHTML = textArea.innerText;
			emailMessage.message = textArea.innerHTML;
			if (this.feedElement.elements[i].capabilities.emailMessage.attachments.length > 0) {
				this.feedElement.elements[i].capabilities.emailMessage.attachments.forEach(ele => {
					const fileType = this.getFileType(ele.fileName);
					let emailAttachment = {
						contentId: ele.attachment.id,
						fileName: ele.fileName,
						fileType: fileType,
						bgColor: this.colorIcon[fileType] == null || this.colorIcon[fileType] == undefined ? this.colorIcon['defaultColor'] : this.colorIcon[fileType]
					}
					emailMessage.attachments.push(emailAttachment);
				})
			}
			return emailMessage;
		}
		return emailMessage;
	}

	/****************************************************************************************** 
	 * Handles spinner after getting value from service cloud.
	 *****************************************************************************************/
	handleSpinner() {
		this.isSpinner = !this.isSpinner;
	}

	/****************************************************************************************** 
	 * Handles toast event.
	 * @param {String} eventType - The eventType containing string value suggesting what type
	 * of toast it is.
	 *****************************************************************************************/
	handleToastEvent(eventType) {
		var event;
		if (eventType === 'Success') {
			event = new ShowToastEvent({
				title: 'Success',
				message: 'Comment Posted!',
				variant: 'success'
			});
		} else if (eventType === 'Error') {
			event = new ShowToastEvent({
				message: 'Issue while fetching data from service cloud',
				variant: 'warning',
				mode: 'dismissable'
			});
		}
		this.dispatchEvent(event);
	}

	/****************************************************************************************** 
	 * Handles filetype to show in svg.
	 * @param {String} fileName - contain the name of file from where we fetch the file type.
	 *****************************************************************************************/
	getFileType(fileName) {
		const dotIndex = fileName.lastIndexOf('.');
		if (dotIndex !== -1 && dotIndex < fileName.length - 1) {
			return fileName.substring(dotIndex + 1).toUpperCase();
		}
		return '';
	}

	/****************************************************************************************** 
	 * Handles attachment content.
	 * @param {Object} event - pass the current event.
	 *****************************************************************************************/
	handleAttachmentContent(event, mimeType = 'application/octet-stream') {
		var fileName = event.target.dataset.filename;
		getContentVersion({
			recordId: event.target.dataset.id
		})
			.then(result => {
				const binaryString = window.atob(result);
				const len = binaryString.length;
				const bytes = new Uint8Array(len);
				for (let i = 0; i < len; i++) {
					bytes[i] = binaryString.charCodeAt(i);
				}
				const blob = new Blob([bytes], {
					type: mimeType
				});
				const url = URL.createObjectURL(blob);
				const a = document.createElement('a');
				a.href = url;
				a.download = fileName;
				document.body.appendChild(a);
				a.click();
				document.body.removeChild(a);
				URL.revokeObjectURL(url);
			})
			.catch(error => {
				console.error('Error retrieving content:', error);
			});
	}

	/****************************************************************************************** 
	 * Handles mention user.
	 * @param {Object} event - pass the current event.
	 *****************************************************************************************/
	handleMention(event) {
		this.message = event.target.value;
		const selection = window.getSelection();
		const anchorOffset = selection.anchorOffset;
		if (this.message === undefined) {
			this.isMentioned = false;
			this.resetMentionPosition();
			return;
		}
		let currentParagraph = '';
		let orginalPTagContent = '';
		const parser = new DOMParser();
		const doc = parser.parseFromString(this.message, 'text/html');

		if (doc) {
			let nearestAtSymbol = null;
			let nearestAtPosition = Infinity;
			let resultContent = '';
			let totalIndex = 0;

			const traverseElement = (element, parentStartIndex) => {
				const strippedContent = element.textContent;
				const atSymbolRegex = /@/g;
				let atMatch;
				let startIndex = parentStartIndex || 0;

				while ((atMatch = atSymbolRegex.exec(strippedContent)) !== null) {
					const atSymbolPosition = startIndex + atMatch.index;
					const distance = Math.abs(atSymbolPosition - anchorOffset);
					if (distance < nearestAtPosition) {
						nearestAtPosition = distance;
						nearestAtSymbol = atSymbolPosition;
						resultContent = strippedContent;
						orginalPTagContent = element.outerHTML;
					}
				}

				Array.from(element.children).forEach(child => {
					traverseElement(child, startIndex);
					startIndex += child.outerHTML.length;
				});
			};

			const elements = doc.querySelectorAll('p, ul, ol');
			elements.forEach(element => {
				traverseElement(element, totalIndex);
				totalIndex += element.outerHTML.length;
			});

			currentParagraph = resultContent;
			currentParagraph = currentParagraph.replace(/<\/?[^>]+(>|$)/g, "").replace('&nbsp;', " ");
		}

		if (currentParagraph.length === 0) {
			this.isMentioned = false;
			this.resetMentionPosition();
			return;
		}

		const adjustedAnchorOffset = this.calculateAdjustedOffset(orginalPTagContent, anchorOffset);
		const cursorPosition = anchorOffset + adjustedAnchorOffset;
		const firstHalf = currentParagraph.substring(0, cursorPosition);
		const mentionPattern = /@([A-Za-z][A-Za-z0-9_]*)(?:\s+[A-Za-z][A-Za-z0-9_]*\s?)?(?:[A-Za-z][A-Za-z0-9_]*\s?)?/g;
		let match;
		this.mentionStartIndex = -1;
		let mentions = [];

		while ((match = mentionPattern.exec(firstHalf)) !== null) {
			mentions.push({ index: match.index, text: match[0].slice(1) });
		}

		let relevantMention = null;
		for (let i = mentions.length - 1; i >= 0; i--) {
			if (mentions[i].index <= cursorPosition) {
				relevantMention = mentions[i];
				if (this.searchTerm === relevantMention.text) {
					relevantMention = null;
					break;
				}
				this.searchTerm = relevantMention.text;
				this.mentionStartIndex = relevantMention.index;
				break;
			}
		}

		if (relevantMention && this.mentionStartIndex !== -1 && this.searchTerm.length > 0) {
			this.fetchMentionedUsers();
			if (selection.rangeCount > 0) {
				const range = selection.getRangeAt(0);
				const rect = range.getBoundingClientRect();
				const editorRect = this.template.querySelector('lightning-input-rich-text').getBoundingClientRect();

				const top = 130 + rect.top - editorRect.top;
				const left = rect.left - editorRect.left;

				this.mentionPosition = {
					top: `${top}px`,
					left: `${left}px`
				};
				this.updateMentionMessageStyles();
				this.isMentioned = true;
				return;
			}
		}

		if (this.mentionStartIndex === -1) {
			this.isMentioned = false;
			this.resetMentionPosition();
		}
	}

	/****************************************************************************************** 
	 * Handles the calculation for offset based for formatting text.
	 * @param {Object} event - pass the current event.
	 *****************************************************************************************/
	calculateAdjustedOffset(htmlContent, anchorOffset) {
		const tempDiv = document.createElement('div');
		htmlContent = htmlContent.replaceAll('&nbsp;', ' ');
		tempDiv.innerHTML = htmlContent;

		let offset = 0;
		let nearestAtPosition = Infinity;
		let nearestAtSymbol = null;
		let resultContent = "";

		const traverse = (node) => {
			if (node.nodeType === Node.TEXT_NODE) {
				const tagContent = node.textContent;
				const pTagStartIndex = offset;
				const pTagEndIndex = pTagStartIndex + tagContent.length;

				const atSymbolRegex = /@/g;
				let atMatch;
				let foundAtSymbol = false;
				while ((atMatch = atSymbolRegex.exec(tagContent)) !== null) {
					const atSymbolPosition = pTagStartIndex + atMatch.index;
					const distance = Math.abs(atSymbolPosition - anchorOffset);

					if (distance < Math.abs(nearestAtPosition - anchorOffset)) {
						nearestAtPosition = atSymbolPosition;
						nearestAtSymbol = atSymbolPosition;
						resultContent = tagContent;
					}
					foundAtSymbol = true;
				}

				if (!foundAtSymbol) {
					offset += tagContent.length;
				}
			} else if (node.nodeType === Node.ELEMENT_NODE) {
				for (let child of node.childNodes) {
					traverse(child);
				}
			}
		};

		traverse(tempDiv);
		return offset;
	}


	/****************************************************************************************** 
	 * Handles mention message styles.
	 * @param {Object} event - pass the current event.
	 *****************************************************************************************/
	updateMentionMessageStyles() {
		const mentionMessageElement = this.template.querySelector('.mention-message');
		if (mentionMessageElement) {
			mentionMessageElement.style.position = 'absolute';
			mentionMessageElement.style.display = 'block';
			mentionMessageElement.style.top = this.mentionPosition.top;
			mentionMessageElement.style.left = this.mentionPosition.left;
		}
	}

	/****************************************************************************************** 
	 * reset mention position after select or multi space.
	 * @param {Object} event - pass the current event.
	 *****************************************************************************************/
	resetMentionPosition() {
		this.mentionPosition = {
			top: '160px',
			left: '62px'
		};
		this.mentionPositionComment = {
			top: '252px',
			left: '120px'
		}
		this.updateMentionMessageStyles();
	}

	/****************************************************************************************** 
	 * Fetch mention user from external Users.
	 * @param {Object} event - pass the current event.
	 *****************************************************************************************/
	fetchMentionedUsers() {
		searchUsers({
			searchTerm: this.searchTerm
		})
			.then((result) => {
				if (result.length > 0) {
					this.isSearchResult = true;
					this.mentionedUsers = result;
				} else {
					this.isSearchResult = false;
					this.mentionedUsers = [];
				}
			})
			.catch((error) => {
				console.error('Error fetching users: ', error);
			});
	}

	/****************************************************************************************** 
	 * Select mention user.
	 * @param {Object} event - pass the current event.
	 *****************************************************************************************/
	selectUser(event) {
		const user = {
			name: event.target.dataset.name,
			id: event.target.dataset.mention
		}
		let userExist = false;
		this.taggedUsers.forEach(u => {
			if (u.id === user.Id) {
				userExist = true;
			}
		})

		if (!userExist) {
			this.taggedUsers.push(user);
		}

		const formattedMention = `<a href="#">[${user.name}]</a>`;
		const mentionRegex = new RegExp(`@(${this.searchTerm})\\b`, 'g');

		if (mentionRegex.test(this.message)) {
			this.message = this.message.replace(mentionRegex, formattedMention);
		}

		this.isMentioned = false;
		this.resetMentionPosition();

		const richTextElement = this.template.querySelector('lightning-input-rich-text');
		if (richTextElement) {
			richTextElement.value = this.message;
		}
	}

	/****************************************************************************************** 
	 * Handle formatting message for Post.
	 * @param {Object} event - pass the current event.
	 *****************************************************************************************/
	formatMessage(inputHtml) {
		const parser = new DOMParser();
		const doc = parser.parseFromString(inputHtml, 'text/html');
		const jsonOutput = [];
		const regex = /\[(.*?)\]/g;



		const processNode = (node) => {
			if (node.nodeType === Node.ELEMENT_NODE) {
				if (node.tagName === 'P') {
					jsonOutput.push({ markupType: 'Paragraph', type: 'MarkupBegin' });
				}
				if (node.tagName === 'STRONG') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'Bold', type: 'MarkupBegin' });
				}
				if (node.tagName === 'LI') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'ListItem', type: 'MarkupBegin' });
				}
				if (node.tagName === 'EM') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'Italic', type: 'MarkupBegin' });
				}
				if (node.tagName === 'U') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'Underline', type: 'MarkupBegin' });
				}
				if (node.tagName === 'A') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'Hyperlink', type: 'MarkupBegin', url: node.href });
				}
				if (node.tagName === 'OL') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'OrderedList', type: 'MarkupBegin' });
				}
				if (node.tagName === 'UL') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'UnorderedList', type: 'MarkupBegin' });
				}
				if (node.tagName === 'STRIKE') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'Strikethrough', type: 'MarkupBegin' });
				}
			}

			if (node.nodeType === Node.TEXT_NODE) {
				const textContent = node.textContent.trim();
				if (textContent) {
					const parts = textContent.split(/(\[[^\]]+\])/);
					parts.forEach(part => {
						const trimmedPart = part.trim();
						if (trimmedPart) {
							const matches = trimmedPart.match(regex);
							if (matches) {
								matches.forEach(match => {
									const mentionName = match.replace(/[\[\]]/g, '');
									const user = this.taggedUsers.find(u => u.name === mentionName);
									if (user) {
										jsonOutput.push({ id: user.id, type: 'Mention' });
										jsonOutput.push({ text: ' ', type: 'Text' });
									}
								});
							} else {
								jsonOutput.push({ text: trimmedPart, type: 'Text' });
								jsonOutput.push({ text: ' ', type: 'Text' });
							}
						}
					});
				}
			}

			Array.from(node.childNodes).forEach(processNode);

			if (node.nodeType === Node.ELEMENT_NODE) {
				if (node.tagName === 'P') {
					jsonOutput.push({ markupType: 'Paragraph', type: 'MarkupEnd' });
				}
				if (node.tagName === 'STRONG') {
					jsonOutput.push({ markupType: 'Bold', type: 'MarkupEnd' });
					jsonOutput.push({ text: ' ', type: 'Text' });
				}
				if (node.tagName === 'EM') {
					jsonOutput.push({ markupType: 'Italic', type: 'MarkupEnd' });
					jsonOutput.push({ text: ' ', type: 'Text' });
				}
				if (node.tagName === 'U') {
					jsonOutput.push({ markupType: 'Underline', type: 'MarkupEnd' });
					jsonOutput.push({ text: ' ', type: 'Text' });
				}
				if (node.tagName === 'A') {
					jsonOutput.push({ markupType: 'Hyperlink', type: 'MarkupEnd' });
					jsonOutput.push({ text: ' ', type: 'Text' });
				}
				if (node.tagName === 'OL') {
					jsonOutput.push({ markupType: 'OrderedList', type: 'MarkupEnd' });
					jsonOutput.push({ text: ' ', type: 'Text' });
				}
				if (node.tagName === 'UL') {
					jsonOutput.push({ markupType: 'UnorderedList', type: 'MarkupEnd' });
					jsonOutput.push({ text: ' ', type: 'Text' });
				}
				if (node.tagName === 'LI') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'ListItem', type: 'MarkupEnd' });
				}
				if (node.tagName === 'STRIKE') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'Strikethrough', type: 'MarkupEnd' });
				}
			}
		};

		Array.from(doc.body.childNodes).forEach(processNode);
		const cleanJSONOutput = this.removeHyperlinkAndKeepMention(jsonOutput);

		const resultString = cleanJSONOutput.map(entry => {
			return JSON.stringify(entry);
		}).join(', ');

		return resultString;
	}

	/****************************************************************************************** 
	 * Handles mention user for comment boxes.
	 * @param {Object} event - pass the current event.
	 *****************************************************************************************/
	handleMentionComment(event) {
		const targetId = event.target.dataset.id;
		const indexId = event.target.dataset.elementid;
		const textareaEditor = this.template.querySelector(`[data-id="${targetId}"]`);
		this.message = event.target.value;

		if (this.message.length === 0) {
			this.feed[indexId].isSomoneMentioned = false;
			this.resetMentionPosition();
			return;
		}
		const selection = window.getSelection();
		const cursorPosition = textareaEditor.selectionStart;
		const firstHalf = this.message.substring(0, cursorPosition);
		const mentionPattern = /@([A-Za-z][A-Za-z0-9_]*)(?:\s+[A-Za-z][A-Za-z0-9_]*\s?)?(?:[A-Za-z][A-Za-z0-9_]*\s?)?/g;
		let match;
		this.mentionStartIndex = -1;
		let mentions = [];

		while ((match = mentionPattern.exec(firstHalf)) !== null) {
			mentions.push({ index: match.index, text: match[0].slice(1) });
		}

		let relevantMention = null;
		for (let i = mentions.length - 1; i >= 0; i--) {
			if (mentions[i].index <= cursorPosition) {
				relevantMention = mentions[i];
				if (this.searchTerm === relevantMention.text) {
					relevantMention = null;
					break;
				}
				this.searchTerm = relevantMention.text;
				this.mentionStartIndex = relevantMention.index;
				break;
			}
		}


		if (relevantMention && this.mentionStartIndex !== -1 && this.searchTerm.length > 0) {
			this.fetchMentionedUsers();
			if (selection.rangeCount > 0) {
				const rect = this.trackCursor(textareaEditor);
				this.mentionPositionComment = {
					top: `${18 + rect.top}px`,
					left: `${rect.left - 20}px`
				};
				if (this.prevMentionedComment !== indexId && this.prevMentionedComment !== undefined) {
					if (this.feed[this.prevMentionedComment].isSomoneMentioned) {
						this.feed[this.prevMentionedComment].isSomoneMentioned = false;
					}
				}
				this.prevMentionedComment = indexId;
				this.feed[indexId].isSomoneMentioned = true;
				this.updateMentionMessageStylesForComment();
				return;
			}
		}

		if (this.mentionStartIndex === -1) {
			this.feed[indexId].isSomoneMentioned = false;
			this.resetMentionPosition();
		}
	}


	/****************************************************************************************** 
	 * Handles mention message styles for comment box.
	 * @param {Object} event - pass the current event.
	 *****************************************************************************************/
	updateMentionMessageStylesForComment() {
		const editorRect = this.template.querySelector('.mention-message-comment');
		if (editorRect) {
			editorRect.style.left = this.mentionPositionComment.left;
			editorRect.style.top = this.mentionPositionComment.top;
			editorRect.style.display = 'block';
		}
	}

	/****************************************************************************************** 
	 * Select mention user for comment section.
	 * @param {Object} event - pass the current event.
	 *****************************************************************************************/
	selectUserForComment(event) {
		const targetId = event.target.dataset.id;
		const indexId = event.target.dataset.elementid;
		const user = {
			name: event.target.dataset.name,
			id: event.target.dataset.mention
		}

		let userExist = false;

		this.taggedUsersInComment.forEach(u => {
			if (u.id === user.id) {
				userExist = true;
			}
		})

		if (!userExist) {
			this.taggedUsersInComment.push(user);
		}

		const formattedMention = `[${user.name}]`;
		const mentionRegex = new RegExp(`@(${this.searchTerm})\\b`, 'g');

		if (mentionRegex.test(this.message)) {
			this.message = this.message.replace(mentionRegex, formattedMention);
		}

		this.feed[indexId].isSomoneMentioned = false;
		this.resetMentionPosition();

		const textEditor = this.template.querySelector(`[data-id="${targetId}"]`);
		if (textEditor) {
			textEditor.value = this.message;
			this.comment = this.message;
		}
	}

	/****************************************************************************************** 
	 * Handle formatting message for comment.
	 * @param {Object} event - pass the current event.
	 *****************************************************************************************/
	formatMessageForComment(message) {
		const lines = message.split('\n');
		const wrappedLines = lines.map(line => `<p>${line}</p>`);
		message = wrappedLines.join('\n');
		const parser = new DOMParser();
		const doc = parser.parseFromString(message, 'text/html');
		const jsonOutput = [];
		const regex = /\[(.*?)\]/g;

		const processNode = (node) => {
			if (node.nodeType === Node.ELEMENT_NODE) {
				if (node.tagName === 'P') {
					jsonOutput.push({ markupType: 'Paragraph', type: 'MarkupBegin' });
				}
				if (node.tagName === 'STRONG') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'Bold', type: 'MarkupBegin' });
				}
				if (node.tagName === 'LI') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'ListItem', type: 'MarkupBegin' });
				}
				if (node.tagName === 'EM') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'Italic', type: 'MarkupBegin' });
				}
				if (node.tagName === 'U') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'Underline', type: 'MarkupBegin' });
				}
				if (node.tagName === 'A') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'Hyperlink', type: 'MarkupBegin', url: node.href });
				}
				if (node.tagName === 'OL') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'OrderedList', type: 'MarkupBegin' });
				}
				if (node.tagName === 'UL') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'UnorderedList', type: 'MarkupBegin' });
				}
				if (node.tagName === 'STRIKE') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'Strikethrough', type: 'MarkupBegin' });
				}
			}

			if (node.nodeType === Node.TEXT_NODE) {
				const textContent = node.textContent.trim();
				if (textContent) {
					const parts = textContent.split(/(\[[^\]]+\])/);
					parts.forEach(part => {
						const trimmedPart = part.trim();
						if (trimmedPart) {
							const matches = trimmedPart.match(regex);
							if (matches) {
								matches.forEach(match => {
									const mentionName = match.replace(/[\[\]]/g, '');
									const user = this.taggedUsersInComment.find(u => u.name === mentionName);
									if (user) {
										jsonOutput.push({ id: user.id, type: 'Mention' });
										jsonOutput.push({ text: ' ', type: 'Text' });
									}
								});
							} else {
								jsonOutput.push({ text: trimmedPart, type: 'Text' });
							}
						}
					});
				}
			}

			Array.from(node.childNodes).forEach(processNode);

			if (node.nodeType === Node.ELEMENT_NODE) {
				if (node.tagName === 'P') {
					jsonOutput.push({ markupType: 'Paragraph', type: 'MarkupEnd' });
				}
				if (node.tagName === 'STRONG') {
					jsonOutput.push({ markupType: 'Bold', type: 'MarkupEnd' });
					jsonOutput.push({ text: ' ', type: 'Text' });
				}
				if (node.tagName === 'EM') {
					jsonOutput.push({ markupType: 'Italic', type: 'MarkupEnd' });
					jsonOutput.push({ text: ' ', type: 'Text' });
				}
				if (node.tagName === 'U') {
					jsonOutput.push({ markupType: 'Underline', type: 'MarkupEnd' });
					jsonOutput.push({ text: ' ', type: 'Text' });
				}
				if (node.tagName === 'A') {
					jsonOutput.push({ markupType: 'Hyperlink', type: 'MarkupEnd' });
					jsonOutput.push({ text: ' ', type: 'Text' });
				}
				if (node.tagName === 'OL') {
					jsonOutput.push({ markupType: 'OrderedList', type: 'MarkupEnd' });
					jsonOutput.push({ text: ' ', type: 'Text' });
				}
				if (node.tagName === 'UL') {
					jsonOutput.push({ markupType: 'UnorderedList', type: 'MarkupEnd' });
					jsonOutput.push({ text: ' ', type: 'Text' });
				}
				if (node.tagName === 'LI') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'ListItem', type: 'MarkupEnd' });
				}
				if (node.tagName === 'STRIKE') {
					jsonOutput.push({ text: ' ', type: 'Text' });
					jsonOutput.push({ markupType: 'Strikethrough', type: 'MarkupEnd' });
				}
			}
		};

		Array.from(doc.body.childNodes).forEach(processNode);
		const resultString = jsonOutput.map(entry => {
			return JSON.stringify(entry);
		}).join(', ');
		return resultString;
	}

	/****************************************************************************************** 
	 * Handles key down operation for rich text input.
	 * @param {Object} event - pass the current event.
	 *****************************************************************************************/
	handleKeydown(event) {
		const richTextElement = this.template.querySelector('lightning-input-rich-text');
		if ((event.key === 'Backspace' || event.key === 'Delete') && window.getSelection().rangeCount > 0) {
			const message = richTextElement.value
			this.previousValue = this.textValue;
			const selection = window.getSelection();
			const range = selection.getRangeAt(0);
			const anchorOffset = selection.anchorOffset;

			if (message === undefined) {
				return;
			}

			const adjustedStartOffset = this.calculateAdjustedOffset(message, anchorOffset);
			const cursorPosition = adjustedStartOffset + anchorOffset;
			const pTags = message.match(/<p>(.*?)<\/p>/g) || [];
			let currentParagraph = '';
			let currentParagraphIndex = -1;
			if (pTags.length > 0) {
				const pTagRegex = /<p>(.*?)<\/p>/g;
				let match;
				let nearestAtSymbol = null;
				let nearestAtPosition = Infinity;
				let resultContent = '';
				while ((match = pTagRegex.exec(message)) !== null) {
					currentParagraphIndex++;
					const pTagContent = match[0];
					const pTagStartIndex = 0;
					const pTagEndIndex = pTagStartIndex + match[0].length;
					const distance = Math.abs(pTagEndIndex - anchorOffset);

					if (distance < nearestAtPosition) {
						nearestAtPosition = distance;
						nearestAtSymbol = pTagEndIndex;
						resultContent = pTagContent;
					}
				}

				currentParagraph = resultContent;
				currentParagraph = currentParagraph;
			}

			if (currentParagraph.length === 0) {
				return;
			}

			const startOffset = range.startOffset + this.calculateAdjustedOffset(currentParagraph, range.startOffset);
			const endOffset = range.endOffset + this.calculateAdjustedOffset(currentParagraph, range.endOffset);
			const tagPattern = /<([a-zA-Z][a-zA-Z0-9]*)\b[^>]*>/g;
			const tagmatches = currentParagraph.match(tagPattern);
			let totalLength = 0;
			if (tagmatches) {
				tagmatches.forEach(tag => {
					totalLength += tag.length;
				});
			}

			const mentionPattern = /\[[^\]]+\]/g;
			let mentions = [];
			let match;
			let index = 0;
			while ((match = mentionPattern.exec(currentParagraph)) !== null) {
				mentions.push({
					mention: match[0],
					start: match.index,
					end: match.index + match[0].length,
					index: index
				});
				index++;
			}

			mentions.sort((a, b) => a.start - b.start);

			let updatedContent = currentParagraph;
			let removedMention = null;
			let mentionToRemove = null;
			let removedMentionIndex = null;
			let removedMentionObject = null;

			for (let i = mentions.length - 1; i >= 0; i--) {
				const { mention, start, end } = mentions[i];
				if (start <= (startOffset + totalLength) && end >= (endOffset + totalLength)) {
					if (event.key === 'Backspace' && start <= (startOffset + totalLength) && end >= (endOffset + totalLength)) {
						mentionToRemove = mention;
					} else if (event.key === 'Delete' && start <= (startOffset + totalLength) && end >= (endOffset + totalLength)) {
						mentionToRemove = mention;
					}
					if (mentionToRemove) {
						updatedContent = updatedContent.slice(0, start) + updatedContent.slice(end);
						removedMention = mentionToRemove;
						removedMentionObject = mentions[i];
						removedMentionIndex = i;
						break;
					}
				}
			}

			if (removedMention) {
				const mentionedPattern = /\[[^\]]+\]/g;
				const pTagRegex = /<p>(.*?)<\/p>/g;
				let newContent = '';
				let lastIndex = 0;
				let match;
				let removedCurrentParaIndex = -1;
				while ((match = pTagRegex.exec(message)) !== null) {
					removedCurrentParaIndex++;
					const pTagContent = match[0];
					let index = 0;
					let matched;
					let mentionWithTags = [];
					let indexAgain = 0;
					while ((matched = mentionedPattern.exec(pTagContent)) !== null) {
						mentionWithTags.push({
							mention: match[0],
							start: matched.index,
							end: matched.index + matched[0].length,
							index: indexAgain
						});
						indexAgain++;
					}
					if (currentParagraphIndex === removedCurrentParaIndex && currentParagraph.length === pTagContent.length && removedMentionObject.start === mentionWithTags[removedMentionIndex].start) {
						newContent += pTagContent.slice(0, mentionWithTags[removedMentionIndex].start) + pTagContent.slice(mentionWithTags[removedMentionIndex].end);
					} else {
						newContent += pTagContent;
					}
				}

				richTextElement.value = newContent;
				const mentionedUser = removedMention.slice(2, -1);
				this.taggedUsers = this.taggedUsers.filter(user => user.name !== mentionedUser);
				event.preventDefault();
			}
		}
	}

	/****************************************************************************************** 
	 * Handles key down operation for rich text input.
	 * @param {Object} event - pass the current event.
	 *****************************************************************************************/
	handleKeydownOfComment(event) {
		const targetId = event.target.dataset.id;
		const indexId = event.target.dataset.elementid;
		const commentBox = this.template.querySelector(`[data-id="${targetId}"]`);
		const message = event.target.value;

		if (message.length === 0) {
			return;
		}

		if ((event.key === 'Backspace' || event.key === 'Delete') && window.getSelection().rangeCount > 0) {
			const selection = window.getSelection();
			const range = selection.getRangeAt(0);
			const startOffset = commentBox.selectionStart;
			const endOffset = commentBox.selectionEnd;
			let content = message;
			const mentionPattern = /\[[^\]]+\]/g;
			let mentions = [];
			let match;

			while ((match = mentionPattern.exec(content)) !== null) {
				mentions.push({
					mention: match[0],
					start: match.index,
					end: match.index + match[0].length
				});
			}

			mentions.sort((a, b) => a.start - b.start);

			let updatedContent = content;
			let removedMention = null;
			let mentionToRemove = null;

			for (let i = mentions.length - 1; i >= 0; i--) {
				const { mention, start, end } = mentions[i];

				if (start <= startOffset && end >= endOffset) {
					if (event.key === 'Backspace' && start <= startOffset && end >= endOffset) {
						mentionToRemove = mention;
					} else if (event.key === 'Delete' && start <= startOffset && end >= endOffset) {
						mentionToRemove = mention;
					}

					if (mentionToRemove) {
						updatedContent = updatedContent.slice(0, start) + updatedContent.slice(end);
						removedMention = mentionToRemove;
						break;
					}
				}
			}

			if (removedMention) {
				commentBox.value = updatedContent;
				const mentionedUser = removedMention.slice(2, -1);
				this.taggedUsers = this.taggedUsersInComment.filter(user => user.name !== mentionedUser);
				event.preventDefault();
			}
		}
	}

	/****************************************************************************************** 
	 * Handles tracking cursor in text area.
	 * @param {Element} textarea - pass the current event.
	 *****************************************************************************************/
	trackCursor(textarea) {
		let rect = null;
		const textareaValue = textarea.value;
		const cursorPosition = textarea.selectionStart;
		const invisibleDiv = document.createElement('div');
		invisibleDiv.contentEditable = true;
		invisibleDiv.style.position = 'absolute';
		invisibleDiv.style.left = `${textarea.offsetLeft}px`;
		invisibleDiv.style.top = `${textarea.offsetTop}px`;
		invisibleDiv.style.width = `${textarea.offsetWidth}px`;
		invisibleDiv.style.opacity = '0';
		invisibleDiv.style.pointerEvents = 'none';
		invisibleDiv.style.whiteSpace = 'pre-wrap';
		invisibleDiv.style.font = getComputedStyle(textarea).font;
		invisibleDiv.style.lineHeight = getComputedStyle(textarea).lineHeight;
		invisibleDiv.style.padding = getComputedStyle(textarea).padding;

		document.body.appendChild(invisibleDiv);
		invisibleDiv.innerText = textareaValue;
		invisibleDiv.innerHTML = textareaValue.replace(/\n/g, '<br>');
		invisibleDiv.focus();
		const range = document.createRange();
		const selection = window.getSelection();

		let totalOffset = 0;
		let targetNode = null;
		let targetOffset = cursorPosition;

		for (let node of invisibleDiv.childNodes) {
			if (node.textContent === '') {
				totalOffset += 1;
			} else {
				const nodeLength = node.textContent.length;
				if (totalOffset + nodeLength >= cursorPosition) {
					targetNode = node;
					targetOffset = cursorPosition - totalOffset;
					break;
				}

				totalOffset += nodeLength;
			}
		}


		if (targetNode) {
			try {
				range.setStart(targetNode, targetOffset);
				range.setEnd(targetNode, targetOffset);
				selection.removeAllRanges();
				selection.addRange(range);
				rect = range.getBoundingClientRect();
			} catch (error) {
				console.error("Error setting the range:", error);
			}
		}
		textarea.focus();
		document.body.removeChild(invisibleDiv);
		return rect;
	}

	/****************************************************************************************** 
	 * Handles message segements and convert them into HTML.
	 * @param {messageSegment} JSON - pass the messageSegement JSON Values.
	*******************************************************************************************/
	convertMessageSegementInHTML(jsonInput) {
		refreshApex(this.orginalCaseRecord);
		let htmlOutput = '';
		let mentionCount = this.caseStatus === 'New' ? 0 : -1;
		jsonInput.forEach(entry => {
			if (entry.type === 'MarkupBegin') {
				switch (entry.markupType) {
					case 'Paragraph':
						htmlOutput += '<p>'
						break;
					case 'OrderedList':
						htmlOutput += '<ol>';
						break;
					case 'UnorderedList':
						htmlOutput += '<ul>';
						break;
					case 'ListItem':
						htmlOutput += '<li>';
						break;
					case 'Bold':
						htmlOutput += '<b>';
						break;
					case 'Italic':
						htmlOutput += '<em>';
						break;
					case 'Underline':
						htmlOutput += '<u>';
						break;
					case 'Strikethrough':
						htmlOutput += '<s>';
						break;
					case 'Hyperlink':
						htmlOutput += `<a href="${entry.url}">`;
						break;
					default:
						break;
				}
			} else if (entry.type === 'MarkupEnd') {
				switch (entry.markupType) {
					case 'Paragraph':
						htmlOutput += '</p>'
						break;
					case 'OrderedList':
						htmlOutput += '</ol>';
						break;
					case 'UnorderedList':
						htmlOutput += '</ul>';
						break;
					case 'ListItem':
						htmlOutput += '</li>';
						break;
					case 'Bold':
						htmlOutput += '</b>';
						break;
					case 'Italic':
						htmlOutput += '</em>';
						break;
					case 'Underline':
						htmlOutput += '</u>';
						break;
					case 'Strikethrough':
						htmlOutput += '</s>';
						break;
					case 'Hyperlink':
						htmlOutput += '</a>';
						break;
					default:
						break;
				}
			} else if (entry.type === 'Text' && !(entry.text.includes('On behalf of'))) {
				htmlOutput += entry.text || '';
			} else if (entry.type === 'Mention' && mentionCount === 0) {
				htmlOutput += entry.text || '';
			} else if (entry.type === 'Mention' && mentionCount === -1) {
				mentionCount++;
			}
		});
		const tempDiv = document.createElement('div');
		tempDiv.innerHTML = htmlOutput;
		tempDiv.querySelectorAll('p').forEach(p => {
			if (!p.innerHTML.trim()) {
				p.remove();
			} else if (p.innerHTML === '&nbsp;\n') {
				p.remove();
			}
		});

		return tempDiv.innerHTML;
	}
	
	/****************************************************************************************** 
	 * Clean JSON Output.
	 * @param {data} JSON - pass the messageSegement JSON Values.
	*******************************************************************************************/
	removeHyperlinkAndKeepMention(data) {
		const result = [];
		let skipNext = false;

		for (let i = 0; i < data.length; i++) {
			const current = data[i];
			if (current.markupType === "Hyperlink" && !skipNext) {
				if (i + 1 < data.length && data[i + 1].type === "Mention") {
					skipNext = true;
					continue;
				}
			}
			if (current.markupType === "Hyperlink" && skipNext) {
				if (current.type === "MarkupEnd") {
					skipNext = false;
					continue;
				}
			}
			result.push(current);
		}

		return result;
	}
}