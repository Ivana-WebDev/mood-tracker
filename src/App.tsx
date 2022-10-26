import React from 'react';
import './App.css';
import Header from './components/header/Header';
import Sidenav from './components/sidenav/Sidenav';

function App() {
  return (
    <div className="App">
     <Header/>
     <div>
      <Sidenav></Sidenav>
     </div>
    </div>
  );
}

export default App;
