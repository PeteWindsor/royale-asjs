////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package org.apache.royale.jewel.beads.controllers
{
	COMPILE::SWF
	{
		import flash.utils.setTimeout;
    }
	import org.apache.royale.core.IBeadController;
	import org.apache.royale.core.IStrand;
	import org.apache.royale.core.IUIBase;
	import org.apache.royale.events.Event;
	import org.apache.royale.events.IEventDispatcher;
	import org.apache.royale.events.MouseEvent;
	import org.apache.royale.jewel.beads.controls.combobox.IComboBoxView;
	import org.apache.royale.jewel.beads.views.ListView;
	import org.apache.royale.jewel.List;
	import org.apache.royale.jewel.supportClasses.combobox.ComboBoxList;
	import org.apache.royale.core.IComboBoxModel;
	import org.apache.royale.core.ISelectionModel;
	
	
	/**
	 *  The ComboBoxController class is responsible for listening to
	 *  mouse event related to ComboBox. Events such as selecting a item
	 *  or changing the sectedItem.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @playerversion AIR 2.6
	 *  @productversion Royale 0.9.4
	 */
	public class ComboBoxController implements IBeadController
	{
		/**
		 *  constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion Royale 0.9.4
		 */
		public function ComboBoxController()
		{
		}
		
		protected var viewBead:IComboBoxView;
		private var list:List;
		private var model:IComboBoxModel;
		
		private var _strand:IStrand;
		
		/**
		 *  @copy org.apache.royale.core.IBead#strand
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion Royale 0.9.4
         *  @royaleignorecoercion org.apache.royale.jewel.beads.controls.combobox.IComboBoxView
         *  @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		public function set strand(value:IStrand):void
		{
			_strand = value;
			model = _strand.getBeadByType(IComboBoxModel) as IComboBoxModel;
			viewBead = _strand.getBeadByType(IComboBoxView) as IComboBoxView;
			if (viewBead) {
				finishSetup();
			} else {
				IEventDispatcher(_strand).addEventListener("viewChanged", finishSetup);
			}
		}

		/**
         *  @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		protected function finishSetup(event:Event = null):void
		{
			IEventDispatcher(viewBead.button).addEventListener(MouseEvent.CLICK, clickHandler);
            IEventDispatcher(viewBead.textinput).addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
         *  @royaleignorecoercion org.apache.royale.core.UIBase
         *  @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		protected function clickHandler(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
			
			viewBead.popUpVisible = true;
			
			IEventDispatcher(viewBead.popup.list).addEventListener(Event.CHANGE, changeHandler);

			// viewBead.popup is ComboBoxList that fills 100% of browser window-> We want List inside
			list = (viewBead.popup as ComboBoxList).list;

			IEventDispatcher(list).addEventListener(MouseEvent.MOUSE_DOWN, handleControlMouseDown);
			IUIBase(viewBead.popup).addEventListener(MouseEvent.MOUSE_DOWN, removePopUpWhenClickOutside);
		}

		protected function handleControlMouseDown(event:MouseEvent):void
		{
			event.stopImmediatePropagation();
		}
		/**
         *  @royaleignorecoercion org.apache.royale.core.UIBase
         *  @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		protected function removePopUpWhenClickOutside(event:MouseEvent = null):void
		{
			IEventDispatcher(list).removeEventListener(MouseEvent.MOUSE_DOWN, handleControlMouseDown);
			IUIBase(viewBead.popup).removeEventListener(MouseEvent.MOUSE_DOWN, removePopUpWhenClickOutside);
			IEventDispatcher(viewBead.popup.list).removeEventListener(Event.CHANGE, changeHandler);
			viewBead.popUpVisible = false;
		}
		
		/**
         *  @royaleignorecoercion org.apache.royale.core.UIBase
         *  @royaleignorecoercion org.apache.royale.events.IEventDispatcher
		 */
		private function changeHandler(event:Event):void
		{
			event.stopImmediatePropagation();
			IEventDispatcher(list).removeEventListener(MouseEvent.MOUSE_DOWN, handleControlMouseDown);
			IUIBase(viewBead.popup).removeEventListener(MouseEvent.MOUSE_DOWN, removePopUpWhenClickOutside);
			IEventDispatcher(viewBead.popup.list).removeEventListener(Event.CHANGE, changeHandler);

			model.selectedItem = ISelectionModel(viewBead.popup.list.getBeadByType(ISelectionModel)).selectedItem;
			viewBead.popUpVisible = false;
			
			IEventDispatcher(_strand).dispatchEvent(new Event(Event.CHANGE));
		}
	}
}
