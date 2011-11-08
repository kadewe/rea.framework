package Shared
{
	/**
	 * A collection of static math functions, calculating things you might need somewhere.
	 */
	public class StaticMath
	{

		
		/**
		 * This is a full working shuffle function. It auto-increases the y-bounds, if there is no more possible placement of an element. The max effort is n*n, before the bounds will increase.
		 * 
		 * @param width	the width of the current element, which will be compared with the others
		 * @param height the height of the current element, which will be compared with the others
		 * @param boundx the maxwidth of the elements target container
		 * @param boundy the maxheight of the elements targetcontainer
		 * @param compare the array of all elements to compare with
		 * @param maxIndex the maximum amount of steps in the compare loop. assume there are only a few elements with a position set before, so the loop breaks at those who still have not obtained a position.
		 * 
		 * @returns Array an array with the new x and y positions
		 */
		public static function getRandomSquarePosition(width:Number,height:Number,boundx:Number,boundy:Number,compare:Array,maxIndex:uint):Array
		{
			var conflict:Boolean=maxIndex!=0?true:false; //there can be no conflict while there are 0 other objects!
			var posX:Number=0;
			var posY:Number=0;
			var maxShuffle:uint = maxIndex*maxIndex;	//shuffle grows exponential
			while(conflict&&maxShuffle>0)	//shuffle until there`s no conflict.
			{
				maxShuffle--;
				posX = Math.ceil(Math.random()*boundx-width);
				posY = Math.ceil(Math.random()*boundy-height);
				while(posX<=0)
				{
					posX = Math.ceil(Math.random()*boundx-width);
				}
				while(posY<=0)
				{
					posY = Math.ceil(Math.random()*boundy-height);
				}
				var hit:Boolean=false; //assume there was no hit / colllision
				for(var i:uint=0;i<maxIndex&&hit==false;i++) //if hit, break loop
				{
					hit = square2squareHit(posX,posY,width,height,compare[i].x,compare[i].y,compare[i].width,compare[i].height);
					conflict = hit;
				}
			}
			if(maxShuffle<=0)
			{
				return 	getRandomSquarePosition(width,height,boundx,boundy+50,compare,maxIndex);
			}
			var newPos:Array = [posX,posY];
			return newPos;
		}
		
		/**
		 * Square to Square hit test working by exclusion, which is more performant for the case, that usually there would be no collision.
		 * 
		 * @param x			x position of the first object
		 * @param y			y position of the first object
		 * @param width		width of the first object
		 * @param height	height of the first object
		 * @param x2		x position of the second object
		 * @param y2		y position of the second object
		 * @param width2	width of the second object
		 * @param height2	height of the second object
		 * 
		 * @returns Boolean true if they hit each other, false if they dont hit
		 */
		public static function square2squareHit(x:Number,y:Number,width:Number,height:Number,x2:Number,y2:Number,width2:Number,height2:Number):Boolean
		{
			if(x>(x2+width2)||(x+width)<x2)
			{
				return false; //no collision
			}
			if(y>(y2+height2)||(y+height)<y2)
			{
				return false; //no collision
			}
			return true; // collision
		}
			
	}
}