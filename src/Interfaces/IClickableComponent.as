package Interfaces
{
	import mx.core.IButton;

	/**
	 * Defines the minimum criteria to be clickable and refer to any object, which many of the buttons need in this app.
	 * 
	 * <p>There are many different Types of buttons in this application, many of them have refer to a sound and therefore we need to generalize the 
	 * properties of a button which makes ist possible to play a sound by clickign itr dragging it</p>
	 */
	public interface IClickableComponent extends IButton
	{
		/**
		 * Get the reference to a specific sound object.
		 */
		function get referringTo():Object;
		
		/**
		 * Get the reference to a specific visible object like an image.
		 */
		function get visibleReference():Object;
	
		/**
		 * Set the reference to a specific sound object.
		 */
		function set referringTo(value:Object):void;
		
		/**
		 * Set the reference to a specific visible object like an image.
		 */
		function set visibleReference(value:Object):void;
	}
}