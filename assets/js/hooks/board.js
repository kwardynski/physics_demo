import * as d3 from "d3";

let BoardHook = {
  mounted() {
    this.handleEvent("init", (init_attrs) => {
      console.log("INIT");
      svg
        .attr("width", init_attrs.board_width)
        .attr("height", init_attrs.board_height);

      svg
        .append("rect")
        .attr("width", init_attrs.board_width)
        .attr("height", init_attrs.board_height)
        .attr("fill", "none")
        .attr("stroke", "black");

      svg
        .append("rect")
        .attr("id", "bat")
        .attr("width", init_attrs.bat_width)
        .attr("height", init_attrs.bat_height)
        .attr("x", init_attrs.bat_x)
        .attr("y", init_attrs.bat_y);

      console.log(init_attrs.ball_x);

      svg
        .append("circle")
        .attr("cx", init_attrs.ball_x)
        .attr("cy", init_attrs.ball_y)
        .attr("r", init_attrs.ball_radius)
        .attr("stroke", "blue")
        .attr("fill", "blue");
    });

    this.handleEvent("move-bat", ({ bat_y }) => {
      d3.select("#bat").attr("y", bat_y);
    });

    this.handleEvent("move-ball", ({ ball_x, ball_y }) => {
      // console.log("move ball");
      d3.select("circle").attr("cx", ball_x).attr("cy", ball_y);
    });

    var svg = d3.select("#field").append("svg");
  },
};

export { BoardHook };
