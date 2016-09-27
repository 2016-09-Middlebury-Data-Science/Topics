#------------------------------------------------------------------------------
# Solutions to Exercises from Lec06.R
#------------------------------------------------------------------------------
# Q1: Modify the Titanic code above to show a visualization that can answer the
# question of if the "Women and children first" policy of who got on the
# lifeboats held true. Hint: the answer is yes.

# Use facets!
data(Titanic)
Titanic <- as.data.frame(Titanic)
ggplot(data=Titanic, aes(x=Class, y=Freq, fill=Survived)) +
  geom_bar(stat="identity", position = "fill") +
  facet_grid(Age ~ Sex)
# We observe that for any class and age, men died more than women (bigger pink
# bars). Also for any class and sex, children (top row) survived at a higher
# rate. Also, it's nice to see that the White Star Line didn't employ any
# children!


# Q2: Investigate how male vs female acceptance varied by department.
# i.e. Slide 17/27 of UCB.pdf
data(UCBAdmissions)
UCB <- as.data.frame(UCBAdmissions)
UCB
ggplot(UCB, aes(x=Gender, y=Freq, fill = Admit)) +
  geom_bar(stat = "identity", position="fill") +
  facet_wrap(~ Dept, nrow = 2) +
  ggtitle("Acceptance Rate Split by Gender & Department") +
  xlab("Gender") +
  ylab("Prop of Applicants")


# Q3. Investigate the "competitiveness" of different departments as measured by
# acceptance rate.
# i.e. Slide 14/27 of UCB.pdf

# We first use the same plot as above, but switch out the Gender variable for Dept.
ggplot(UCB, aes(x=Dept, y=Freq, fill = Admit)) +
  geom_bar(stat = "identity", position="fill") +
  ggtitle("Acceptance Rate Split by Department") +
  xlab("Dept") +
  ylab("% of Applicants")

# Why are the colors mixed? b/c UCB has the admittance split by Gender. So
# aggregate over Gender by group_by Admit and Dept:
UCB_competitiveness <- UCB %>%
  group_by(Admit, Dept) %>%
  summarise(Freq=sum(Freq))

# Much better:
ggplot(UCB_competitiveness, aes(x=Dept, y=Freq, fill = Admit)) +
  geom_bar(stat = "identity", position="fill") +
  ggtitle("Acceptance Rate Split by Department") +
  xlab("Dept") +
  ylab("% of Applicants")

# Eye candy:  change up the color scheme by changing scale
# See http://colorbrewer2.org/ for different palette names
ggplot(UCB_competitiveness, aes(x=Dept, y=Freq, fill = Admit)) +
  geom_bar(stat = "identity", position="fill") +
  ggtitle("Acceptance Rate Split by Department") +
  xlab("Dept") +
  ylab("% of Applicants") + scale_fill_brewer(palette="Pastel1")
