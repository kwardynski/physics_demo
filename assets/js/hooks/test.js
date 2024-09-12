import * as d3 from "d3";

let TestHook = {
  mounted() {
    this.handleEvent("update-circle", ({ color, x, y }) => {
      d3.select("circle").style("fill", color).attr("cx", x).attr("cy", y);
    });

    var width = 300;
    var height = 300;

    var svg = d3
      .select("#test")
      .append("svg")
      .attr("width", width)
      .attr("height", height);

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
      .attr("stroke", "black")
      .attr("fill", "rgb(255, 0, 255)");
  },
};

export { TestHook };
