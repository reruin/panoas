package  {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

public class Clip extends Sprite {
private var m_selectBox:Bitmap;
private var m_dotBmpd:BitmapData;
private var m_dotTopLeft:Sprite;
private var m_dotTop:Sprite;
private var m_dotTopRight:Sprite;
private var m_dotLeft:Sprite;
private var m_dotRight:Sprite;
private var m_dotBottomLeft:Sprite;
private var m_dotBottom:Sprite;
private var m_dotBottomRight:Sprite;
private var m_target:Sprite;

private var m_dotWidth:uint;
private var m_dotHeight:uint;
private var m_oldMouseX:int;
private var m_oldMouseY:int;

public function Clip() {
this.m_selectBox = new Bitmap(new BitmapData(10, 10, true, 0x20ff0000));
this.m_dotBmpd = new BitmapData(5, 5, false, 0);
this.createSelection();
}

private function createSelection():void {
this.addChild(this.m_selectBox);
var bmd:BitmapData = this.m_dotBmpd;
this.m_dotWidth = bmd.width;
this.m_dotHeight = bmd.height;

this.m_dotLeft = new Sprite();
this.m_dotLeft.addChild(new Bitmap(bmd));
this.m_dotRight = new Sprite();
this.m_dotRight.addChild(new Bitmap(bmd));
this.addChild(this.m_dotLeft);
this.addChild(this.m_dotRight);
this.m_dotLeft.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseEventHandler);
this.m_dotRight.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseEventHandler);

this.m_dotTop = new Sprite();
this.m_dotTop.addChild(new Bitmap(bmd));
this.m_dotBottom = new Sprite();
this.m_dotBottom.addChild(new Bitmap(bmd));
this.addChild(this.m_dotTop);
this.addChild(this.m_dotBottom);
this.m_dotTop.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseEventHandler);
this.m_dotBottom.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseEventHandler);

this.m_dotBottomLeft = new Sprite();
this.m_dotBottomLeft.addChild(new Bitmap(bmd));
this.m_dotBottomRight = new Sprite();
this.m_dotBottomRight.addChild(new Bitmap(bmd));
this.m_dotTopLeft = new Sprite();
this.m_dotTopLeft.addChild(new Bitmap(bmd));
this.m_dotTopRight = new Sprite();
this.m_dotTopRight.addChild(new Bitmap(bmd));
this.addChild(this.m_dotBottomLeft);
this.addChild(this.m_dotBottomRight);
this.addChild(this.m_dotTopLeft);
this.addChild(this.m_dotTopRight);
this.m_dotBottomLeft.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseEventHandler);
this.m_dotBottomRight.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseEventHandler);
this.m_dotTopLeft.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseEventHandler);
this.m_dotTopRight.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseEventHandler);

this.m_selectBox.width = 100;
this.m_selectBox.height = 100;
this.updateDotPosition();
}

private function updateDotPosition():void {
var width:uint = this.m_selectBox.width;
var height:uint = this.m_selectBox.height;
var dotHalfWidth:uint = this.m_dotWidth >> 1;
var dotHalfHeight:uint = this.m_dotHeight >> 1;
this.m_dotLeft.x = -dotHalfWidth + this.m_selectBox.x;
this.m_dotRight.x = width - dotHalfWidth - 1 + this.m_selectBox.x;
this.m_dotLeft.y = this.m_dotRight.y = (height >> 1) - dotHalfHeight + this.m_selectBox.y;
this.m_dotTop.x = this.m_dotBottom.x = (width >> 1) - dotHalfWidth + this.m_selectBox.x;
this.m_dotTop.y = -dotHalfHeight + this.m_selectBox.y;
this.m_dotBottom.y = height - dotHalfHeight - 1 + this.m_selectBox.y;
this.m_dotTopLeft.x = this.m_dotBottomLeft.x = -dotHalfWidth + this.m_selectBox.x;
this.m_dotTopLeft.y = this.m_dotTopRight.y = -dotHalfHeight + this.m_selectBox.y;
this.m_dotBottomLeft.y = this.m_dotBottomRight.y = height - dotHalfHeight - 1 + this.m_selectBox.y;
this.m_dotTopRight.x = this.m_dotBottomRight.x = width - dotHalfWidth - 1 + this.m_selectBox.x;
}

private function mouseEventHandler(evt:MouseEvent):void {
switch(evt.type) {
case MouseEvent.MOUSE_DOWN:
evt.stopImmediatePropagation();
this.m_oldMouseX = stage.mouseX;
this.m_oldMouseY = stage.mouseY;
this.m_target = Sprite(evt.currentTarget);
stage.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseEventHandler);
stage.addEventListener(MouseEvent.MOUSE_UP, this.mouseEventHandler);
break;
case MouseEvent.MOUSE_UP:
this.stopDrag();
this.m_target = null;
stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.mouseEventHandler);
stage.removeEventListener(MouseEvent.MOUSE_UP, this.mouseEventHandler);
break;
case MouseEvent.MOUSE_MOVE:
var offsetX:int = stage.mouseX - this.m_oldMouseX;
var offsetY:int = stage.mouseY - this.m_oldMouseY;
var width:uint = this.m_selectBox.width;
var height:uint = this.m_selectBox.height;
switch(this.m_target) {
case this.m_dotTop:
this.changeHeightY(offsetY, height, this.m_dotBottom);
break;
case this.m_dotBottom:
this.changeHeight(offsetY, height, this.m_dotTop);
break;
case this.m_dotLeft:
this.changeWidthX(offsetX, width, this.m_dotRight);
break;
case this.m_dotRight:
this.changeWidth(offsetX, width, this.m_dotLeft);
break;
case this.m_dotTopLeft:
this.changeWidthX(offsetX, width, this.m_dotTopRight);
if (this.m_target == this.m_dotTopRight) {
this.changeHeightY(offsetY, height, this.m_dotBottomRight);
}else {
this.changeHeightY(offsetY, height, this.m_dotBottomLeft);
}
break;
case this.m_dotTopRight:
this.changeWidth(offsetX, width, this.m_dotTopLeft);
if (this.m_target == this.m_dotTopLeft) {
this.changeHeightY(offsetY, height, this.m_dotBottomLeft);
}else {
this.changeHeightY(offsetY, height, this.m_dotBottomRight);
}
break;
case this.m_dotBottomLeft:
this.changeWidthX(offsetX, width, this.m_dotBottomRight);
if (this.m_target == this.m_dotBottomRight) {
this.changeHeight(offsetY, height, this.m_dotTopRight);
}else {
this.changeHeight(offsetY, height, this.m_dotTopLeft);
}
break;
case this.m_dotBottomRight:
this.changeWidth(offsetX, width, this.m_dotBottomLeft);
if (this.m_target == this.m_dotBottomLeft) {
this.changeHeight(offsetY, height, this.m_dotTopLeft);
}else {
this.changeHeight(offsetY, height, this.m_dotTopRight);
}
break;
}
break;
}
}

private function changeWidth(offset:int, width:uint, nextTarget:Sprite):void {
if (offset == 0) return;
offset = width + offset;
if (offset < 1) {
this.m_selectBox.x += offset;
this.m_selectBox.width = Math.abs(offset) + 1;
this.m_target = nextTarget;
}else {
this.m_selectBox.width = offset;
}
this.m_oldMouseX = stage.mouseX;
this.updateDotPosition();
}
private function changeWidthX(offset:int, width:uint, nextTarget:Sprite):void {
if (offset == 0) return;
offset = width - offset;
if (offset < 1) {
this.m_selectBox.x += width - 1;
this.m_selectBox.width = Math.abs(offset) + 1;
this.m_target = nextTarget;
}else {
this.m_selectBox.width = offset;
this.m_selectBox.x += width - offset;
}
this.m_oldMouseX = stage.mouseX;
this.updateDotPosition();
}
private function changeHeight(offset:int, height:uint, nextTarget:Sprite):void {
if (offset == 0) return;
offset = height + offset;
if (offset < 1) {
this.m_selectBox.y += offset;
this.m_selectBox.height = Math.abs(offset) + 1;
this.m_target = nextTarget;
}else {
this.m_selectBox.height = offset;
}
this.m_oldMouseY = stage.mouseY;
this.updateDotPosition();
}
private function changeHeightY(offset:int, height:uint, nextTarget:Sprite):void {
if (offset == 0) return;
offset = height - offset;
if (offset < 1) {
this.m_selectBox.y += height - 1;
this.m_selectBox.height = Math.abs(offset) + 1;
this.m_target = nextTarget;
}else {
this.m_selectBox.height = offset;
this.m_selectBox.y += height - offset;
}
this.m_oldMouseY = stage.mouseY;
this.updateDotPosition();
}
}
}