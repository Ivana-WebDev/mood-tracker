import React from "react";
import "./Sidenav.scss";
import { BsArrowRightCircleFill } from "react-icons/bs";

function Sidenav(): JSX.Element {
  return (
    <div className="sidenav">
      <BsArrowRightCircleFill />
      <div className="sidenav-content">
        <ul>
            <li>
                <a href="/">Mood Board</a>
            </li>
            <li>
                <button>Add new</button>
            </li>
        </ul>

      </div>
    </div>
  );
}

export default Sidenav;
