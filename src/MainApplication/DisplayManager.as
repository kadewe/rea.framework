/*

"Rich E-Assesment (REA) Framework"
A software framework for the use within the domain of e-assessment.

Copyright (C) 2014  University of Bremen, 
Working Group education media | media education 

Prof. Dr. Karsten Wolf, wolf@uni-bremen.de
Dipl.-Päd. Ilka Koppel, ikoppel@uni-bremen.de
Dipl.-Math. Kai Schwedes, kais@zait.uni-bremen.de
B.Sc. Jan Küster, jank87@tzi.de

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/
package MainApplication
{
	import events.TrackingEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import spark.components.BorderContainer;
	import spark.components.Image;
	
	
	/**
	 * The DisplayManager is one of the core classes to provide a handler for all visual components, send from MainAppManager.
	 * This allows the <code>MainAppManager</code> to include or remove specific view components of a module.
	 * 
	 * @see MainApplication.MainAppManager
	 * 
	 */
	public class DisplayManager extends BorderContainer
	{
		
		/**
		 * Constructor, empty.
		 */
		public function DisplayManager()
		{
		}
		
		//----------------------------------------------------//
		//
		//		CONSTS AND VARIABLES
		//
		//----------------------------------------------------//	
		
		/**
		 * @private The target view reference, which will be dispalyed on the screen.
		 */
		private var viewReference:Object;
		
		
		
		//----------------------------------------------------//
		//
		//			PUBLIC METHODS
		//
		//----------------------------------------------------//				

		
		/**
		 * Invokes display tracking procedure.
		 */
		public function startDisplayTracking(trackMouseDown:Boolean=true,trackMouseMove:Boolean=true,trackKeyPressed:Boolean=true):void
		{
			if(trackMouseDown)addEventListener(MouseEvent.MOUSE_DOWN, onGlobalMousePressed);
			if(trackMouseMove)addEventListener(MouseEvent.MOUSE_MOVE, onGlobalMouseMove);
			if(trackKeyPressed)addEventListener(KeyboardEvent.KEY_UP, onGlobalKeyPressed);
		}
		
		/**
		 * Links the Displaymanager with the viewcomponent of the actual module.
		 * 
		 * @param ob an object reference to the actual module
		 * @param _title defined, wether the tween is the title screen or a normal alpha tween
		 * 
		 * @see layer the image which will be faded to alpha 0
		 * @see #showDisplay() the tween animation
		 */
		public function applyView(ob:Object,_title:Boolean=false):void
		{

			viewReference = ob;
			viewReference.visible=true;
			this.addElement(viewReference as IVisualElement);			
			this.visible=true;
		}
		
		/**
		 * Clears the screen.
		 */
		public function removeView():void
		{
			removeAllElements();
			viewReference = null;
		}
		

		
		//----------------------------------------------------//
		//
		//	METHODS ON TRACKING
		//
		//----------------------------------------------------//

		
		/**
		 * Makes a screenshot of the references view and injects it into an Image.
		 * 
		 * @return Image (spark image) with current screen as source data or null of an error occured 
		 */
		public function screenshot():Image
		{
			try
			{
				var target:UIComponent=viewReference as UIComponent;	
				var bd:BitmapData = new BitmapData(target.width,target.height);
					bd.draw(target);
				var bitmap:Bitmap = new Bitmap(bd);
				var im:Image = new Image();
					im.source = bitmap;
					im.visible=false;
				this.addElement(im);
				return im;
			} 
			catch(error:Error) 
			{
				
			}
			return null;
		}
		
		/**
		 * @private
		 */
		private function onGlobalMousePressed(event:MouseEvent):void
		{	
			dispatchEvent(new TrackingEvent(TrackingEvent.INPUT_OCCURED,false,false,
				event.stageX,
				event.stageY,
				"",
				false,
				true,
				false,
				event.target
			));
		}
		
		/**
		 * @private
		 */
		private function onGlobalKeyPressed(event:KeyboardEvent):void
		{
			dispatchEvent(new TrackingEvent(TrackingEvent.INPUT_OCCURED,false,false,
				stage.mouseX,
				stage.mouseY,
				returnKeyAsString(
					event.altKey,
					event.ctrlKey,
					event.shiftKey,
					event.charCode
					),
				false,
				false,
				true
			));
			
		}
		
		/**
		 * @private
		 */
		private function onGlobalMouseMove(event:MouseEvent):void
		{
			dispatchEvent(new TrackingEvent(TrackingEvent.INPUT_OCCURED,false,false,
				event.stageX,
				event.stageY,
				"",
				true,
				false,
				false,
				event.target
			));
		}
		
		/**
		 * @private
		 */
		private function returnKeyAsString(alt:Boolean,ctrl:Boolean,shift:Boolean,charCode:uint):String
		{
			var keyString:String="";
			if(alt)keyString+="alt ";
			if(ctrl)keyString+="ctrl ";
			if(shift)keyString+="shift";
			
			if(charCode!=0)
			{
				try
				{
					keyString+=String.fromCharCode(charCode);	
				} 
				catch(error:Error) 
				{
					keyString+=charCode.toString();	
				}
			}
			return keyString;
		}
	}
}