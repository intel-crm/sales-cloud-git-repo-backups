// /** gallery images
//  *
//  * @param {*} contentWrapper objectData.contentWrapper
//  *
//  * @returns {string[]} image urls for product gallery
//  */
// export default function extractGalleryImages(contentWrapper = []) {
  
//   return contentWrapper.map((img, idx) => ({
//     accountId: img.accountId === null ? null : img.accountId, 
//     videoId: img.videoId === null ? null : img.videoId,
//     videoType: img.videoType === null ? null : img.videoType,
//     title: img.title === null ? null : img.title,
//     imageUrl: img.imageUrl === null? null : (img.videoId === null ? `/file-asset/${img.imageUrl}?isOptimized=false`:img.imageUrl), 
//     thumbnailUrl: img.thumbnailUrl === null ? null : `/file-asset/${img.thumbnailUrl || img.imageUrl}?isOptimized=false`,
//     videoThumbnailUrl: img.videoThumbnailUrl === null ? null : img.videoThumbnailUrl,
//     description: img.description === null ? null : img.description,
//     placeholder1920px: img.placeholder1920px === null ? null : img.placeholder1920px,
//     placeholder246px: img.placeholder246px === null ? null : img.placeholder246px,
//     altText: img.altText === null ? null : img.altText,
//     }));
// }
export default class galleryImages extends LightningElement{}