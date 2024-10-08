import * as d3 from "d3";

let BallHook = {
  mounted() {
    this.handleEvent("init", ({ width, height }) => {
      svg.attr("width", width).attr("height", height);

      svg
        .append("rect")
        .attr("width", width)
        .attr("height", height)
        .attr("fill", "none")
        .attr("stroke", "black");

      svg
        .append("circle")
        .attr("cx", 20)
        .attr("cy", 100)
        .attr("r", 5)
        .attr("stroke", "white")
        .attr("fill", "white");
    });

    this.handleEvent("update-circle", ({ x, y }) => {
      d3.select("circle").style("fill", "black").attr("cx", x).attr("cy", y);
    });

    var svg = d3.select("#ball-field").append("svg");
  },
};

export { BallHook };
