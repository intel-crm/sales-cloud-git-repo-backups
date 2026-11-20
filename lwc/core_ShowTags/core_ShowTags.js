import { LightningElement } from 'lwc';
import TagModal from 'c/core_TagsPopup';
export default class Core_ShowTags extends LightningElement {
    async openTags() {
        await TagModal.open({size: 'small'});
    }
}