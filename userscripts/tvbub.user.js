// ==UserScript==
// @name        tradingbubbles
// @namespace   mbulat.com
// @include     *
// @version     1
// ==/UserScript==
var input=document.createElement("input");
input.type="button";
input.value="TV";
input.onclick = showAlert;
document.body.appendChild(input); 
function showAlert()
{
    alert("TV");
}