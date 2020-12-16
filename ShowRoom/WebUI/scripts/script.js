
document.getElementById("vehicle").addEventListener('mousedown', OnMouseDown);

document.getElementById("soldier").addEventListener('mousedown', OnMouseDown);
document.getElementById("soldier").addEventListener('wheel', OnWheel);

document.addEventListener('mouseup', OnMouseUp);

function OnMouseDown(event){
	if (event.button === 0) {
		WebUI.Call('DispatchEvent', 'Showroom:MouseButtonLevel', 1);
	}
}

function OnMouseUp(event){
	if (event.button === 0) {
		WebUI.Call('DispatchEvent', 'Showroom:MouseButtonLevel', 0);
	}
}

function OnWheel(event){
	WebUI.Call('DispatchEvent', 'Showroom:MouseWheelLevel', event.deltaY);
}


function EnableSoldierOverlay(enable) {
	document.getElementById('soldier').hidden = !enable;
}

function EnableVehicleOverlay(enable) {
	document.getElementById('vehicle').hidden = !enable;
}
