package MainApplication
{
	import DisplayApplication.ErrorView;
	
	import Shared.ErrorDispatcher;
	
	import enumTypes.ErrorTypeEnum;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.Image;
	import mx.core.IVisualElement;
	import mx.managers.CursorManager;
	
	import spark.components.BorderContainer;
	
	
	/**
	 * The DisplayManager is one of the core classes to provide a management all visual components.
	 * This allows the <code>MainAppmanager</code> to include or remove specific view components of a module.
	 * 
	 * @see MainApplication.MainAppManager
	 * 
	 */
	public class DisplayManager extends BorderContainer
	{

		//------------------------------------
		//	VARIABLES
		//------------------------------------

		
		/**
		 * The target object, which will be dispalyed on the screen.
		 */
		public var inheritedObj:Object;
		
		private var layer:Image = new Image();		//layer image for faking transition
		private var title:Image = new Image();		//title image
		private var timer:Timer;
		private var timeCount:Number=100;
		
		/**
		 * Event Const for dispatching status of tweened out / fade out complete.
		 * 
		 * @eventType flash.events.Event
		 * @see layer
		 */
		public static const DISPLAY_TWEENEDOUT:String = "displayTweenedOut";
		
		public static const DISPLAY_ERROR:String = "dispalyError";
		
		//----------------------------------------------------//
		//
		//			PUBLIC METHODS
		//
		//----------------------------------------------------//				
		
		/**
		 * Constructor, no args. Set the default size of the wrapper.
		 */
		public function DisplayManager()
		{
			this.width = 1100;
			this.minWidth = 1000;
			this.height = 800;
			this.minHeight=700;
			trace("[displaymanager]: created");
			layer.source="Assets/layer.png";
			title.source="Assets/title.png";
			title.x=0;
			title.y=0;
			layer.x=0;
			layer.y=0;
			timer=new Timer(20);
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
		public function setContent(ob:Object,_title:Boolean=false):void
		{
			//timer=new Timer(20);
			
			layer.width = 1500;
			layer.height =1000;
			layer.x = -20;
			layer.y = -20;
			layer.alpha=1;
			inheritedObj = ob;
			inheritedObj.visible=false;
			this.addElement(inheritedObj as IVisualElement);			
			if(_title)
			{	
				this.addElement(title);
				timer.start();
				CursorManager.setBusyCursor();
				timer.addEventListener(TimerEvent.TIMER, showTitle);
			}else{
					this.addElement(layer);
					timer.start();
					CursorManager.setBusyCursor();
					timer.addEventListener(TimerEvent.TIMER, showDisplay);				
			}
			inheritedObj.visible=true;
			this.visible=true;
		}
		
		/**
		 * clears the screen.
		 */
		public function removeContent():void
		{
			trace("[displaymanager]: remove display object reference");
			this.removeAllElements();
			inheritedObj = null;
		}
		
		
		
		//----------------------------------------------------//
		//
		//			PRIVATE METHODS
		//
		//----------------------------------------------------//
		
		/**
		 * @private
		 */
		private function showDisplay(event:TimerEvent):void
		{
			layer.alpha-=0.018;
			if(layer.alpha <=0)
			{
				CursorManager.removeAllCursors();
				layer.alpha=1;
				layer.width=0;
				layer.height=0;
				try
				{
					timer.stop();
					timer.removeEventListener(TimerEvent.TIMER, showDisplay);
					timer.reset();
					trace("[displaymanager]:tween finished and removed");
					dispatchEvent(new Event(DisplayManager.DISPLAY_TWEENEDOUT));
				}catch(e:Error){
					trace(e.message);
				}
			}
		}
		
		/**
		 * @private
		 */
		private function showTitle(event:TimerEvent):void
		{
			timeCount-=1;
			if(timeCount<=0)
			{
				title.alpha-=0.005;
				inheritedObj.visible=true;
				if(title.alpha <=0)
				{
					CursorManager.removeAllCursors();
					title.alpha=1;
					title.width=0;
					title.height=0;
					try
					{
						timer.stop();
						timer.removeEventListener(TimerEvent.TIMER, showTitle);
						timer.reset();
						trace("[displaymanager]:tween finished and removed");
						dispatchEvent(new Event(DisplayManager.DISPLAY_TWEENEDOUT));
					}catch(e:Error){
						trace(e.message);
					}
				}
			}

		}
		
	}
}