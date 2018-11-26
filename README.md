# nickr: Checking Data Integrity in Pipelines

This package provides functions that can be inserted between stages of a magrittr pipeline to check that data satisfies user-specified conditions without modifying that data.  Users can specify conditions on rows, columns, or groups as expressions, define their own error messages, control the way that error reports are logged, and enable or disable filters selectively so that they can be left in place in production.

nickr is inspired by Stochastic Solutions' "test-driven data analysis" <http://www.tdda.info/> and Poisson Consulting's checkr package <https://poissonconsulting.github.io/checkr/>.
