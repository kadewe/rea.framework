package DisplayApplication.Components
{
	import Interfaces.ICustomEventDispatcher;
	import Interfaces.ICustomSelectable;
	
	import Shared.CustomImage;
	import Shared.StaticFunctions;
	
	import flash.filters.GlowFilter;
	
	/**
	 * A simple extension of an image, inmplementing the selectable idea. This image can be uses with others to simulate an image based single- or multiple choice construct.
	 */
	public class SelectableImage extends CustomImage implements ICustomSelectable
	{
		
		private var _selected:Boolean=false;
		private var _hovered:Boolean=false;
		
		public var hoverColor:uint = 0xFFD779;
		public var selectedColor:uint =0x4466FF;
		
		/**
		 * Constructor.
		 * 
		 * @see Shared.CustomImage
		 */
		public function SelectableImage(scriptUrl:String,relativePath:String)
		{
			super(scriptUrl, relativePath);
		}
		
		/**
		 * set this component to the selected status, which will also change the appearance to a colored border.
		 */
		public function set selected(value:Boolean):void
		{
			_selected = value;
			if(value)
			{
				var glo:flash.filters.GlowFilter = Shared.StaticFunctions.getGloFil(selectedColor);
				filters = [glo];
			}else{
				filters=null;
			}
		}
		
		/**
		 * set this component to the hovered status, which will also change the appearance to a colored border.
		 */
		public function set hovered(value:Boolean):void
		{
			_hovered = value;
			if(!selected)
			{
				if(value)
				{
					var glo:flash.filters.GlowFilter = Shared.StaticFunctions.getGloFil(hoverColor);
					filters = [glo];
				}else{
					filters = null;
				}	
			}
			
		}
		
		/**
		 * access the selected property
		 */
		public function get selected():Boolean
		{
			return _selected;
		}
		
		/**
		 * access the hovered property
		 * 
		 */
		public function get hovered():Boolean
		{
			return _hovered;
		}
		
	}
}