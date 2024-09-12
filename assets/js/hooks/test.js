import * as d3 from "d3";

let TestHook = {
  mounted() {
    var position;

    var width = 300;
    var height = 300;

    var svg = d3
      .select("#test")
      .append("svg")
      .attr("width", width)
      .attr("height", height);

    svg
      .append("circle")
      .attr("cx", 100)
      .attr("cy", 100)
      .attr("r", 50)
      .attr("stroke", "black")
      .attr("fill", "#ffff");
  },
};

export { TestHook };
