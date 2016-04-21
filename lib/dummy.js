'use babel';

import DummyView from './dummy-view';
import { CompositeDisposable } from 'atom';

export default {

  dummyView: null,
  modalPanel: null,
  subscriptions: null,

  activate(state) {
    this.dummyView = new DummyView(state.dummyViewState);
    this.modalPanel = atom.workspace.addModalPanel({
      item: this.dummyView.getElement(),
      visible: false
    });

    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'dummy:toggle': () => this.toggle()
    }));
  },

  deactivate() {
    this.modalPanel.destroy();
    this.subscriptions.dispose();
    this.dummyView.destroy();
  },

  serialize() {
    return {
      dummyViewState: this.dummyView.serialize()
    };
  },

  toggle() {
    console.log('Dummy was toggled!');
    return (
      this.modalPanel.isVisible() ?
      this.modalPanel.hide() :
      this.modalPanel.show()
    );
  }

};
