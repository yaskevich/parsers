startList = function() {
if (document.all&&document.getElementById) {
for (j=1; j<=6; j++){
this["navRoot"+j] = document.getElementById("M"+j)
}

for (i=0; i< this.navRoot2.childNodes.length; i++) {
node2 = this.navRoot2.childNodes[i];
if (node2.nodeName=="LI") {
node2.onmouseover=function() {
this.className+=" over";
}
node2.onmouseout=function() {
this.className=this.className.replace(" over", "");
   }
   }
  }

for (i=0; i< this.navRoot1.childNodes.length; i++) {
node1 = this.navRoot1.childNodes[i];
if (node1.nodeName=="LI") {
node1.onmouseover=function() {
this.className+=" over";
}
node1.onmouseout=function() {
this.className=this.className.replace(" over", "");
   }
   }
  }

for (i=0; i< this.navRoot3.childNodes.length; i++) {
node3 = this.navRoot3.childNodes[i];
if (node3.nodeName=="LI") {
node3.onmouseover=function() {
this.className+=" over";
}
node3.onmouseout=function() {
this.className=this.className.replace(" over", "");
   }
   }
  }

for (i=0; i< this.navRoot4.childNodes.length; i++) {
node4 = this.navRoot4.childNodes[i];
if (node4.nodeName=="LI") {
node4.onmouseover=function() {
this.className+=" over";
}
node4.onmouseout=function() {
this.className=this.className.replace(" over", "");
   }
   }
  }
for (i=0; i< this.navRoot5.childNodes.length; i++) {
node5 = this.navRoot5.childNodes[i];
if (node5.nodeName=="LI") {
node5.onmouseover=function() {
this.className+=" over";
}
node5.onmouseout=function() {
this.className=this.className.replace(" over", "");
   }
   }
  }
for (i=0; i< this.navRoot6.childNodes.length; i++) {
node6 = this.navRoot6.childNodes[i];
if (node6.nodeName=="LI") {
node6.onmouseover=function() {
this.className+=" over";
}
node6.onmouseout=function() {
this.className=this.className.replace(" over", "");
   }
   }
  }

 }
}
window.onload=startList;