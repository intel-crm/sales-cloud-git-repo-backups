import { LightningElement, track } from 'lwc';

import supportFooterTemplate from './ipaSupportFooter.html';
import loadingTemplate from './loading.html';
import { getSupportFooter } from 'c/ipaBenefitService';

export default class IpaSupportFooter extends LightningElement {
    @track isLoading = true;
    @track title = '';
    @track cards = [];

    connectedCallback(){
        this.fetchSupportFooter();
    }
    render() {
        return this.isLoading ? loadingTemplate : supportFooterTemplate;
    }

    async fetchSupportFooter() {
        const result = await new Promise (resolve => {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(()=>{
                getSupportFooter().then((value) => {
                    resolve(value);
                });
            }, 2000);
        });

        this.title = result.title;
        this.cards  = result.cards.map((card,cardIndex) => {
            // add ids to tree
            let content = card.content.map((item, contentIndex) => ({
                    ...item,
                    id: 'content-' + cardIndex + '-' + contentIndex,
                    isLinks:  (item.type === 'links'),
                    isText:  (item.type === 'text'),
                    isRichText:  (item.type === 'richtext'),
                    body: (item.type === 'links') ? this.addIds(item.body, 'link-' + cardIndex + '-' + contentIndex) : item.body
            }));
            return {
                ...card,
                id: 'card-' + cardIndex,
                content: content
            }
        });
        console.log('getSupportFooter',result, JSON.parse(JSON.stringify(this.cards)));
        this.isLoading = false;
    }

    addIds(arr, prefix){
        if (arr && arr.length > 0) {
            return arr.map((item,index) => ({
                ...item,
                id: prefix + '-' + index
            }));
        }
        return arr;
    }


}