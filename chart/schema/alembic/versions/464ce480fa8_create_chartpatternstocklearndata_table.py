"""create chartPatternStockLearnData Table

Revision ID: 464ce480fa8
Revises: 1498c821e325
Create Date: 2015-07-16 15:20:28.943000

"""

# revision identifiers, used by Alembic.
revision = '464ce480fa8'
down_revision = '1498c821e325'
branch_labels = None
depends_on = None

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.create_table(
        'chartPatternStockLearnData',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('patternId', sa.Integer, sa.ForeignKey('patternMaster.id'), nullable=False),
        sa.Column('stockCode', sa.String(5), nullable=False),
        sa.Column('startDate', sa.TIMESTAMP, nullable=False),
        sa.Column('endDate', sa.TIMESTAMP, nullable=False),
        sa.Column('judgment', sa.Integer, nullable=False)
    )



def downgrade():
    op.drop_table('chartPatternStockLearnData')
