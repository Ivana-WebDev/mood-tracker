import { BsList } from "react-icons/bs";
import "./Header.scss";

function Header(): JSX.Element {
  return (
    <div className="header">
        <div className="header-wrapper">
      <div className="header-item">
       <div className="logo-wrapper">
       <a href="/" >
        <img className="logo" src={require('../../global/images/logo.png')} />
        </a>
        <h2>Mood Tracker</h2>
       </div>
        </div>
      <div className="header-item">
        <ul>
          <li className="dropdown">
            <a href="javascript:void(0)" className="dropbtn">
             <BsList />
            </a>
            <div className="dropdown-content">
              <a href="#">Link 1</a>
              <a href="#">Link 2</a>
              <a href="#">Link 3</a>
            </div>
          </li>
        </ul>
      </div>
    </div>
    </div>
  );
}

export default Header;
