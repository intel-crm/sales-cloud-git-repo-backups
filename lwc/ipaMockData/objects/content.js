/** Contact
 * Data used to display the optional contacts part of the benefit
 * @typedef Content
 * @property {string} type the type of the content text/links/richtex
 * @property {string|Link[]} body the body can be text|richtext|link array depending on the type
 */

import helpers from './helpers/index';
import {mockLinks} from './link';

const textSample = ( ) => {
    return helpers.sample(['Contact us anytime to create a support request', 'Contact Chat available Monday to Friday 8:30am to 4:30pm PST', 'Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit']);
}
const richTextSample = ( ) => {
    return helpers.sample(["Call <a href='tel:+13174562564'>1-866-655-6565</a> Monday to Friday 8:30am to 4:30pm",
                            "Contact Chat <a href='tel:+13174562564'>available</a> Monday to Friday 8:30am to 4:30pm PST",
                            "Neque porro quisquam est qui dolorem i <a href='tel:+13174562564'>available</a> consectetur, adipisci velit",
                            "quia dolor sit amet <a href='tel:+13174562564'>available</a> consectetur, adipisci velit",
                            "dolorem ipsum quia dolort <a href='tel:+13174562564'>available</a> consectetur, adipisci velit"]);
}

const randomNumber = (mod) => {
    return (Math.floor((Math.random()* 100 )) % mod) + 1;
}
export const mockContentType = (index, linkCount) => {

    let mockContent = [
        {
            type: 'text',
            body: textSample()
        },
        {
            type: 'richtext',
            body: richTextSample()
        },
        {
            type: 'links',
            body: mockLinks(linkCount || randomNumber(5))
        }
    ];

    return  index>-1  && mockContent.length > index ? mockContent[index] : helpers.sample(mockContent);
}

export const mockContent = (count) => {
    let returnSet = [];
    let resultCount = count || randomNumber(4);
    while(returnSet.length < resultCount){
        returnSet.push(mockContentType())
    }
    return returnSet;
}