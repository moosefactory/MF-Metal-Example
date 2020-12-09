/*--------------------------------------------------------------------------*/
/*   /\/\/\__/\/\/\        MooseFactory Foundation - v2.0                   */
/*   \/\/\/..\/\/\/                                                         */
/*        |  |             (c)2007-2020 Tristan Leblanc                     */
/*        (oo)             tristan@moosefactory.eu                          */
/* MooseFactory Software                                                    */
/*--------------------------------------------------------------------------*/
/*
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. */
/*--------------------------------------------------------------------------*/

//  UserAction.swift
//  MoofFoundation
//
//  Created by Tristan Leblanc on 04/12/2020.


import Foundation

/// User action protocol
///
/// The name of the action will be displayed in UI ( Button title, menu item, undo/redo menu )
protocol UserAction {
    /// Action name
    var name: String { get }
    
    /// Execute action
    func execute() throws
    
    /// Undo action
    func undo() throws
}

typealias UserActionResult = Result<Any?,Error>

typealias UserActionCompletion = ((UserActionResult)->Void)?

class UserActionManager {
    
    enum Errors: String, Error {
        case undoStackIsEmpty
        case redoStackIsEmpty
    }
    
    var stack = [UserAction]()
    var redoStack = [UserAction]()
    
    var undoManager: UndoManager?
    
    init(undoManager: UndoManager?) {
        self.undoManager = undoManager
    }
    
    func execute(action: UserAction, closure: UserActionCompletion = nil) {
        do {
            try action.execute()
            undoManager?.setActionName(action.name)
            undoManager?.registerUndo(withTarget: self, handler: { target in
                target.undo(closure: closure)
            })
            closure?(UserActionResult.success(nil))
            stack.append(action)
        } catch {
            closure?(UserActionResult.failure(error))
        }
    }
    
    func undo(closure: UserActionCompletion = nil) {
        guard let action = stack.popLast() else {
            closure?(UserActionResult.failure(Errors.undoStackIsEmpty))
            return
        }
        
        do {
            try action.undo()
            redoStack.append(action)
            undoManager?.registerUndo(withTarget: self, handler: { target in
                target.redo(closure: closure)
            })
            closure?(UserActionResult.success(nil))
        } catch {
            closure?(UserActionResult.failure(error))
        }
    }
    
    func redo(closure: UserActionCompletion = nil) {
        guard let action = redoStack.popLast() else {
            closure?(UserActionResult.failure(Errors.redoStackIsEmpty))
            return
        }
        execute(action: action, closure: closure)
    }
}

