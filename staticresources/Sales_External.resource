function checkAndToggleChannelMenu() {
document.getElementsByClassName("helpButtonLabel")[0].click();
alert('+++++');
console.log('alert');
esw = document.getElementsByClassName("helpButtonLabel")[0];
if (esw == null) {
setTimeout(checkAndToggleChannelMenu2, 4000);
}else{
esw.click();
}
function checkAndToggleChannelMenu2() {
var esw = document.getElementsByClassName("helpButtonLabel")[0];
if (esw == null) {
setTimeout(checkAndToggleChannelMenu3, 2000);
} else {
esw.click();
}
function checkAndToggleChannelMenu3() {
var esw = document.getElementsByClassName("helpButtonLabel")[0];
esw.click();
}
setTimeout(checkAndToggleChannelMenu, 8000);