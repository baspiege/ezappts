function checkAll(field, checked) {
    if (field) {
        if (field.length) {
            for (var i=0; i<field.length; i++) {
                field[i].checked=checked;
            }
        } //If only one, then not array. Field will be the only checkbox.
        else {
            field.checked=checked;
        }
    }
}

function checkCol(element,index) {
    if (typeof(element.isChecking)=='undefined'){
        element.isChecking=true;
    }
    var rows=document.getElementById("sched").getElementsByTagName("tr");
    // Start at 1 because first row is dates.
    for (var i=1;i<rows.length;i++){
        checkInputs(rows[i].getElementsByTagName("td")[index],element.isChecking);
    }
    // Update toggle
    element.isChecking=!element.isChecking;
}

function checkRow(element,index) {
    if (typeof(element.isChecking)=='undefined'){
        element.isChecking=true;
    }
    var cols=document.getElementById("sched").getElementsByTagName("tr")[index].getElementsByTagName("td");
    for (var i=0;i<cols.length;i++){
        checkInputs(cols[i],element.isChecking);
    }
    // Update toggle
    element.isChecking=!element.isChecking;
}

function checkInputs(element,isChecking) {
    var inputs=element.getElementsByTagName("input");
    for (var i=0;i<inputs.length;i++){
        inputs[i].checked=isChecking;
    }
}

// Mouse starting positions.
var _startX = 0;
var _startY = 0;

// Current element offset.
var _offsetX = 0;
var _offsetY = 0;

// Needs to be passed from OnMouseDown to OnMouseMove
var _dragElement;

// Temporarily increase the z-index during drag
var _oldZIndex = 0;

InitDragDrop();

function InitDragDrop() {
    document.onmousedown = OnMouseDown;
    document.onmouseup = OnMouseUp;
}

function OnMouseDown(e) {
    // Set event for IE
    if (e == null) e = window.event;

    // IE uses srcElement, others use target
    var target = e.target != null ? e.target : e.srcElement;

    // For IE, left click == 1. For Firefox, left click == 0
    if ((e.button == 1 && window.event != null || e.button == 0) && target.className && target.className.indexOf("drag")!=-1) {
        target.style.position = "relative";

        // Grab the mouse position
        _startX = e.clientX;
        _startY = e.clientY;

        // Grab the clicked element's position
        _offsetX = ExtractNumber(target.style.left);
        _offsetY = ExtractNumber(target.style.top);

        // Bring the clicked element to the front while it is being dragged
        _oldZIndex = target.style.zIndex;
        target.style.zIndex = 10000;

        // For access the element in OnMouseMove
        _dragElement = target;

        // Start moving the element with the mouse
        document.onmousemove = OnMouseMove;

        // Cancel out any text selections
        document.body.focus();

        // Prevent text selection in IE
        document.onselectstart = function () {
            return false;
        };

        // Prevent IE from trying to drag an image
        target.ondragstart = function () {
            return false;
        };

        // Prevent text selection (except IE)
        return false;
    }
}

function ExtractNumber(value) {
    var n = parseInt(value);
    return n == null || isNaN(n) ? 0 : n;
}

function OnMouseMove(e) {
    if (e == null) var e = window.event;
    _dragElement.style.left = (_offsetX + e.clientX - _startX) + 'px';
    _dragElement.style.top = (_offsetY + e.clientY - _startY) + 'px';
}

function OnMouseUp(e)
{
    if (_dragElement != null)
    {
        _dragElement.style.zIndex = _oldZIndex;

        // Set event for IE
        if (e == null){
            var e = window.event;
        }

        var clientX=mouseX(e);
        var clientY=mouseY(e);
        var moving=false;

        // Check if in row.
        var rows=document.getElementById("sched").getElementsByTagName("tr");
        // Start at 1 because first row is dates.
        for (var i=1;i<rows.length;i++){
            if (checkInElement(rows[i], clientX, clientY)){
                // Check if in cell.
                var cols=rows[i].getElementsByTagName("td");
                for (var j=0;j<cols.length;j++){
                    if (checkInElement(cols[j], clientX, clientY)){

                        var userId=rows[i].getAttribute("id");
                        var dateAppt=rows[0].getElementsByTagName("th")[j+1].getAttribute("id");
                        var inputs=_dragElement.getElementsByTagName("input");
                        if (inputs && inputs.length>0)
                        {
                            var apptId=inputs[0].value;

                            // Get form and submit it.
                            var moveForm = document.getElementById("moveForm");
                            createInput(moveForm, "dateMove", dateAppt);
                            createInput(moveForm, "userIdMove", userId);
                            createInput(moveForm, "apptId", apptId);
                            saveSchedPos();
                            moveForm.submit();
                            
                            moving=true;
                        }
                    }
                }
            }
        }

        // Revert back.
        if (!moving)
        {
            _dragElement.style.position = "static";
            _dragElement.style.left = 0; // Put back to orig?
            _dragElement.style.top = 0; // Put back to orig?
        }

        // Reset events until next onmousedown
        document.onmousemove = null;
        document.onselectstart = null;
        _dragElement.ondragstart = null;
        _dragElement = null;
    }
}

function scrollX() {
    return document.documentElement.scrollLeft ? document.documentElement.scrollLeft : document.body.scrollLeft;
}

function scrollY() {
    return document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop;
}

function mouseX(evt) {
    if (evt.pageX) {
        return evt.pageX;
    }
    else if (evt.clientX) {
        return evt.clientX + scrollX();
    }
    else return null;
}

function mouseY(evt) {
    if (evt.pageY) {
        return evt.pageY;
    }
    else if (evt.clientY) {
        return evt.clientY + scrollY();
    }
    else return null;
}

function findPos(obj) {
    var curleft = curtop = 0;
    if (obj.offsetParent) {
        do {
            curleft += obj.offsetLeft;
            curtop += obj.offsetTop;
        } while (obj = obj.offsetParent);
    }
    return [curleft, curtop];
}

function checkInElement(element, posX, posY) {
    var positions = findPos(element);
    var targPosX = positions[0];
    var targPosY = positions[1];
    var targWidth = ExtractNumber(element.offsetWidth);
    var targHeight = ExtractNumber(element.offsetHeight);
    if ((posX > targPosX) && (posX < (targPosX + targWidth)) && (posY > targPosY) && (posY < (targPosY + targHeight))) {
        return true;
    }
    return false;
}

function createInput(form, name, value){
    var newInput = document.createElement("input");
    newInput.name = name;
    newInput.value = value;
    newInput.type = "hidden";
    form.appendChild(newInput);
}

function saveSchedPos() {
    createCookie("schedX","",-1);
    createCookie("schedY","",-1);
    createCookie("schedX",scrollX(),1);
    createCookie("schedY",scrollY(),1);
}

function createCookie(name,value,days) {
    if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        var expires = "; expires="+date.toGMTString();
    }
    else var expires = "";
    document.cookie = name+"="+value+expires+"; path=/";
}