"""create chartPatternWinRate

Revision ID: 32a51c34353e
Revises: 2fc8063fdce2
Create Date: 2015-08-25 10:16:50.828000

"""

# revision identifiers, used by Alembic.
revision = '32a51c34353e'
down_revision = '2fc8063fdce2'
branch_labels = None
depends_on = None

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.create_table(
        'chartPatternWinRate',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('patternId', sa.Integer, nullable=False),
        sa.Column('winRate', sa.Float, nullable=False),
        sa.Column('targetRate', sa.Float),
    )
    pass


def downgrade():
    op.drop_table('chartPatternWinRate')
    pass
